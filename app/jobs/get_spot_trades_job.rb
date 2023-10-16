class GetSpotTradesJob < ApplicationJob
  queue_as :daily_job
  TRADE_SYMBOL = 'USDT'.freeze
  SOURCE = 'binance'.freeze
  SKIP_SYMBOLS = ['BUSD'].freeze

  def perform(symbol, user_id: nil)
    return if symbol.in?(SKIP_SYMBOLS)
    origin_symbol = "#{symbol}#{TRADE_SYMBOL}"
    txs = OriginTransaction.where(source: SOURCE, original_symbol: origin_symbol, user_id: user_id)
    trades = BinanceSpotsService.new(user_id: user_id).get_my_trades(origin_symbol)
    current_price = get_current_price(origin_symbol, user_id)
    if trades.is_a?(String) || trades.blank?
      Rails.logger.debug "获取不到#{origin_symbol}的交易记录"
      txs.each{|tx| update_tx(tx, current_price)} if txs.any?
      combine_trades(origin_symbol, current_price)
      return false
    end

    ids = []
    OriginTransaction.transaction do
      trades.each do |trade|
        trade_type = trade[:isBuyer] ? 'buy' : 'sell'
        tx = OriginTransaction.where(source: SOURCE, order_id: trade[:id], user_id: user_id, event_time: Time.at(trade[:time] / 1000))
                              .first_or_create(original_symbol: trade[:symbol], from_symbol: symbol, to_symbol: TRADE_SYMBOL, fee_symbol: trade[:commissionAsset],
                                               price: trade[:price], qty: trade[:qty], amount: trade[:quoteQty], fee: trade[:commission], trade_type: trade_type)
        update_tx(tx, current_price)
        ids.push(tx.id)
      end

      txs.where.not(id: ids).each do |tx|
        update_tx(tx, current_price)
      end

      combine_trades(origin_symbol, current_price) if user_id.nil?
    end

    $redis.del("origin_transactions_total_summary_#{user_id}")
  end

  def get_current_price(symbol, user_id)
    price = $redis.get("binance_spot_price_#{symbol}").to_f
    if price == 0
      price = BinanceSpotsService.new(user_id: user_id).get_price(symbol)[:price] rescue 0
      $redis.set("binance_spot_price_#{symbol}", price, ex: 2.hours)
    end

    price.to_f
  end

  def update_tx(tx, current_price)
    tx.current_price = current_price
    tx.cost = get_spot_cost(tx.user_id, tx.original_symbol, tx.event_time.to_date) || tx.price
    tx.revenue = get_revenue(tx.trade_type, tx.amount, tx.cost, tx.qty, current_price)
    tx.roi = tx.revenue / tx.amount
    tx.save
  end

  def combine_trades(symbol, current_price)
    CombineTransaction.transaction do
      total_cost = 0
      total_qty = 0
      total_fee = 0
      total_sold_revenue = 0

      origin_txs = OriginTransaction.available.year_to_date.where(user_id: nil, source: SOURCE, original_symbol: symbol).order(event_time: :asc)
      return if origin_txs.empty?
      origin_txs.each do |tx|
        if tx.trade_type == 'buy'
          total_cost += tx.amount
          total_qty += tx.qty
        else
          total_cost -= tx.amount
          total_qty -= tx.qty
          total_sold_revenue += tx.revenue
        end

        total_fee += tx.fee
      end

      origin_tx = origin_txs.first
      trade_type = total_cost > 0 ? 'buy' : 'sell'
      combine_tx = CombineTransaction.where(source: SOURCE, original_symbol: symbol, from_symbol: origin_tx.from_symbol, to_symbol: origin_tx.to_symbol, fee_symbol: origin_tx.fee_symbol, trade_type: trade_type).first_or_create

      price = total_cost / total_qty
      revenue = trade_type == 'buy' ? current_price * total_qty - total_cost : total_cost.abs - current_price * total_qty
      roi = revenue / total_cost.abs

      combine_tx.update(price: price, qty: total_qty, amount: total_cost, fee: total_fee, current_price: current_price, revenue: revenue, roi: roi, sold_revenue: total_sold_revenue)
    end
  end

  def get_revenue(trade_type, amount, cost, qty, current_price)
    if trade_type == 'sell'
      amount - cost * qty
    else
      current_price * qty - amount
    end
  end

  def get_spot_cost(user_id, origin_symbol, date)
    cost = SpotBalanceSnapshotRecord.joins(:spot_balance_snapshot_info)
            .find_by(spot_balance_snapshot_info: {user_id: user_id, event_date: date}, origin_symbol: origin_symbol, source: SOURCE)&.price.to_f
    cost = UserSpotBalance.find_by(user_id: user_id, origin_symbol: origin_symbol, source: SOURCE)&.price.to_f if cost.zero? && date == Date.today
    cost
  end
end
