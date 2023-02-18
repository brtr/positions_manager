class GetSpotTradesJob < ApplicationJob
  queue_as :daily_job
  TRADE_SYMBOL = 'USDT'.freeze
  SOURCE = 'binance'.freeze
  SKIP_SYMBOLS = ['BUSD'].freeze

  def perform(symbol)
    return if symbol.in?(SKIP_SYMBOLS)
    origin_symbol = "#{symbol}#{TRADE_SYMBOL}"
    txs = OriginTransaction.where(source: SOURCE, original_symbol: origin_symbol)
    trades = BinanceSpotsService.get_my_trades(origin_symbol, from_date: Date.yesterday)
    if trades.is_a?(String) || trades.blank?
      Rails.logger.debug "获取不到#{origin_symbol}的交易记录"
      txs.each{|tx| update_tx(tx)} if txs.any?
      combine_trades(origin_symbol)
      return false
    end

    ids = []
    OriginTransaction.transaction do
      trades.each do |trade|
        trade_type = trade[:isBuyer] ? 'buy' : 'sell'
        tx = OriginTransaction.where(source: SOURCE, order_id: trade[:orderId])
                              .first_or_create(original_symbol: trade[:symbol], from_symbol: symbol, to_symbol: TRADE_SYMBOL, fee_symbol: trade[:commissionAsset], trade_type: trade_type,
                                               price: trade[:price], qty: trade[:qty], amount: trade[:quoteQty], fee: trade[:commission], event_time: Time.at(trade[:time] / 1000))
        update_tx(tx)
        ids.push(tx.id)
      end

      txs.where.not(id: ids).each do |tx|
        update_tx(tx)
      end

      combine_trades(origin_symbol)
    end

    $redis.del('origin_transactions_total_summary')
  end

  def get_current_price(symbol)
    price = $redis.get("binance_spot_price_#{symbol}").to_f
    if price == 0
      price = BinanceSpotsService.get_price(symbol)[:price] rescue 0
      $redis.set("binance_spot_price_#{symbol}", price, ex: 2.hours)
    end

    price
  end

  def update_tx(tx)
    tx.current_price = get_current_price(tx.original_symbol)
    tx.revenue = tx.current_price * tx.qty - tx.amount
    tx.roi = tx.revenue / tx.amount
    tx.save
  end

  def combine_trades(symbol)
    CombineTransaction.transaction do
      total_cost = 0
      total_qty = 0
      total_fee = 0

      origin_txs = OriginTransaction.where(source: SOURCE, original_symbol: symbol).order(event_time: :asc)
      return if origin_txs.empty?
      origin_txs.each do |tx|
        if tx.trade_type == 'buy'
          total_cost += tx.amount
          total_qty += tx.qty
        else
          total_cost -= tx.amount
          total_qty -= tx.qty
        end

        total_fee += tx.fee
      end

      origin_tx = origin_txs.first
      trade_type = total_cost > 0 ? 'buy' : 'sell'
      combine_tx = CombineTransaction.where(source: SOURCE, original_symbol: symbol, from_symbol: origin_tx.from_symbol, to_symbol: origin_tx.to_symbol, fee_symbol: origin_tx.fee_symbol, trade_type: trade_type).first_or_create

      price = total_cost / total_qty
      current_price = get_current_price(symbol)
      revenue = trade_type == 'buy' ? current_price * total_qty - total_cost : total_cost.abs - current_price * total_qty
      roi = revenue / total_cost.abs

      combine_tx.update(price: price, qty: total_qty, amount: total_cost, fee: total_fee, current_price: current_price, revenue: revenue, roi: roi)
    end
  end
end
