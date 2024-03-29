class GetGateSpotTradesJob < ApplicationJob
  queue_as :daily_job
  SOURCE = 'gate'.freeze
  FEE_SYMBOL = 'USDT'.freeze

  def perform(user_id: nil)
    result = GateSpotsService.new.get_trades rescue nil
    return if result.blank?

    txs = OriginTransaction.where(source: SOURCE, user_id: user_id)
    ids = []

    OriginTransaction.transaction do
      result.each do |d|
        order_id = d['id']
        next if OriginTransaction.exists?(order_id: order_id, user_id: user_id, source: SOURCE)
        original_symbol = d['currency_pair']
        qty = d['amount'].to_f
        price = d['price'].to_f
        amount = qty * price
        trade_type = d['side'].downcase
        from_symbol = original_symbol.split("_#{FEE_SYMBOL}")[0]
        event_time = Time.at(d['create_time'].to_i)
        cost = get_spot_cost(user_id, original_symbol, event_time.to_date) || price
        current_price = get_current_price(original_symbol, user_id, from_symbol)
        revenue = get_revenue(trade_type, amount, cost, qty, current_price)
        roi = revenue / amount
        tx = OriginTransaction.where(order_id: order_id, user_id: user_id, source: SOURCE).first_or_initialize
        tx.update(
          original_symbol: original_symbol,
          from_symbol: from_symbol,
          to_symbol: FEE_SYMBOL,
          fee_symbol: d['fee_currency'],
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
    end
  end

  def get_current_price(symbol, user_id, from_symbol)
    price = $redis.get("gate_spot_price_#{symbol}").to_f
    if price == 0
      price = GateSpotsService.new(user_id: user_id).get_price(symbol).first["last"].to_f rescue 0
      price = CoinService.get_price_by_date(from_symbol) if price.zero?
      $redis.set("gate_spot_price_#{symbol}", price, ex: 2.hours)
    end

    price.to_f
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

  def get_revenue(trade_type, amount, cost, qty, current_price)
    if trade_type == 'sell'
      amount - cost * qty
    else
      current_price * qty - amount
    end
  end

  def get_spot_cost(user_id, origin_symbol, date)
    cost = SpotBalanceSnapshotRecord.joins(:spot_balance_snapshot_info)
            .find_by(spot_balance_snapshot_info: {user_id: user_id, event_date: date}, origin_symbol: origin_symbol, source: SOURCE)&.price
    cost = UserSpotBalance.find_by(user_id: user_id, origin_symbol: origin_symbol, source: SOURCE)&.price if cost.nil? && date == Date.today
    cost
  end
end
