class GetUsersSpotTransactionsJob < ApplicationJob
  queue_as :daily_job
  FEE_SYMBOL = 'USDT'.freeze

  def perform(user_id=nil)
    if user_id
      get_binance_orders(user_id)
      get_okx_orders(user_id)
    else
      user_ids = User.where('api_key is not null and secret_key is not null').ids
      user_ids.each do |user_id|
        get_binance_orders(user_id)
        get_okx_orders(user_id)
      end
    end

    ForceGcJob.perform_later
  end

  def get_binance_orders(user_id)
    data = BinanceSpotsService.new(user_id: user_id).get_account rescue nil
    return if data.nil?

    assets = data[:balances].select{|i| i[:free].to_f != 0 || i[:locked].to_f != 0}.map{|i| i[:asset]}

    assets += SpotBalanceHistory.where(event_date: Date.yesterday, user_id: user_id).pluck(:asset)

    assets.uniq.each do |asset|
      GetSpotTradesJob.perform_later(asset, user_id: user_id)
    end
  end

  def get_okx_orders(user_id)
    result = OkxSpotsService.new(user_id: user_id).get_orders rescue nil
    return if result.nil?

    OriginTransaction.transaction do
      result['data'].each do |d|
        next if d['category'] != 'normal'
        original_symbol = d['instId']
        qty = d['accFillSz'].to_f
        price = d['avgPx'].to_f
        amount = qty * price
        revenue = d['pnl'].to_f
        trade_type = d['side'].downcase
        from_symbol = original_symbol.split("-#{FEE_SYMBOL}")[0]
        current_price = get_current_price(original_symbol, user_id)
        revenue = current_price * qty - amount if revenue.to_f.zero?
        roi = revenue / amount
        tx = OriginTransaction.where(order_id: d['ordId'], user_id: user_id).first_or_initialize
        tx.update(
          source: 'okx',
          original_symbol: original_symbol,
          from_symbol: from_symbol,
          to_symbol: FEE_SYMBOL,
          fee_symbol: d['rebateCcy'],
          trade_type: trade_type,
          price: price,
          qty: qty,
          amount: amount,
          fee: d['fee'].to_f.abs,
          revenue: revenue,
          roi: roi,
          current_price: current_price,
          event_time: Time.at(d['cTime'].to_i / 1000)
        )
      end
    end
  end

  def get_current_price(symbol, user_id)
    price = $redis.get("okx_spot_price_#{symbol}").to_f
    if price == 0
      price = OkxSpotsService.new(user_id: user_id).get_price(symbol)["data"].first["last"] rescue 0
      $redis.set("okx_spot_price_#{symbol}", price, ex: 2.hours)
    end

    price.to_f
  end
end
