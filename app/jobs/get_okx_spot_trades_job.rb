class GetOkxSpotTradesJob < ApplicationJob
  queue_as :daily_job
  SOURCE = 'okx'.freeze
  FEE_SYMBOL = 'USDT'.freeze

  def perform(user_id: nil)
    result = OkxSpotsService.new.get_orders rescue nil
    return if result.nil? || result['data'].nil?

    txs = OriginTransaction.where(source: SOURCE, user_id: user_id)
    ids = []

    OriginTransaction.transaction do
      result['data'].each do |d|
        next if d['category'] != 'normal'
        next if OriginTransaction.exists?(order_id: d['ordId'], user_id: user_id, source: 'okx')
        original_symbol = d['instId']
        qty = d['accFillSz'].to_f
        price = d['avgPx'].to_f
        amount = qty * price
        revenue = d['pnl'].to_f
        trade_type = d['side'].downcase
        from_symbol = original_symbol.split("-#{FEE_SYMBOL}")[0]
        event_time = Time.at(d['cTime'].to_i / 1000)
        cost = get_spot_cost(user_id, original_symbol, event_time.to_date) || price
        current_price = get_current_price(original_symbol, user_id, from_symbol)
        revenue = get_revenue(trade_type, amount, cost, qty, current_price) if revenue.to_f == 0
        roi = revenue / amount
        tx = OriginTransaction.where(order_id: d['ordId'], user_id: user_id, source: SOURCE).first_or_initialize
        tx.update(
          original_symbol: original_symbol,
          from_symbol: from_symbol,
          to_symbol: FEE_SYMBOL,
          fee_symbol: d['rebateCcy'],
          trade_type: trade_type,
          price: price,
          qty: qty,
          amount: amount,
          fee: d['fee'].to_f.abs,
          cost: cost,
          revenue: revenue,
          roi: roi,
          current_price: current_price,
          event_time: event_time
        )
        update_tx(tx)
        ids.push(tx.id)
      end

      txs.where.not(id: ids).each do |tx|
        update_tx(tx)
      end

      combine_trades if user_id.nil?
    end
  end

  def get_current_price(symbol, user_id, from_symbol)
    price = $redis.get("okx_spot_price_#{symbol}").to_f
    if price == 0
      price = OkxSpotsService.new(user_id: user_id).get_price(symbol)["data"].first["last"].to_f rescue 0
      price = get_coin_price(from_symbol) if price.zero?
      $redis.set("okx_spot_price_#{symbol}", price, ex: 2.hours)
    end

    price.to_f
  end

  def get_coin_price(symbol)
    date = Date.yesterday
    url = ENV['COIN_ELITE_URL'] + "/api/coins/history_price?symbol=#{symbol}&from_date=#{date}&to_date=#{date}"
    response = RestClient.get(url)
    data = JSON.parse(response.body)
    data['result'].values[0].to_f rescue nil
  end

  def update_tx(tx)
    tx.current_price = get_current_price(tx.original_symbol, tx.user_id, tx.from_symbol)
    if tx.cost.to_f.zero?
      tx.cost = get_spot_cost(tx.user_id, tx.original_symbol, tx.event_time.to_date) || tx.price
    end
    tx.revenue = get_revenue(tx.trade_type, tx.amount, tx.cost, tx.qty, tx.current_price)
    tx.roi = tx.revenue / tx.amount
    tx.save
  end

  def combine_trades
    CombineTransaction.transaction do
      OriginTransaction.available.year_to_date.where(user_id: nil, source: SOURCE).order(event_time: :asc).group_by(&:original_symbol).each do |original_symbol, origin_txs|
        total_cost = 0
        total_qty = 0
        total_fee = 0
        total_sold_revenue = 0

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
        combine_tx = CombineTransaction.where(source: SOURCE, original_symbol: original_symbol, from_symbol: origin_tx.from_symbol, to_symbol: origin_tx.to_symbol,
                                              fee_symbol: origin_tx.fee_symbol, trade_type: 'buy').first_or_create

        price = total_qty.zero? ? 0 : total_cost / total_qty
        revenue = origin_tx.current_price * total_qty - total_cost
        roi = revenue / total_cost.abs

        combine_tx.update(price: price, qty: total_qty, amount: total_cost, fee: total_fee, current_price: origin_tx.current_price, revenue: revenue, roi: roi, sold_revenue: total_sold_revenue)
      end
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
