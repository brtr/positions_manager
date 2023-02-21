class GetPublicUserPositionsJob < ApplicationJob
  queue_as :daily_job

  def perform
    binance_data = BinanceFuturesService.new.get_positions
    okx_data = OkxFuturesService.get_positions
    huobi_data = HuobiFuturesService.get_positions
    ids = []

    binance_data["positions"].select{|i| i["positionAmt"].to_f != 0}.each do |d|
      fee_symbol = d["symbol"].include?("USDT") ? "USDT" : "BUSD"
      from_symbol = d["symbol"].split(fee_symbol)[0]
      qty = d["positionAmt"].to_f
      t_type = qty > 0 ? "sell" : "buy"
      up = get_up(d["symbol"], fee_symbol, from_symbol, t_type, 'binance')
      ids.push(up.id)
      up.update(price: d["entryPrice"].to_f, qty: qty.abs)

      get_info(up)
    end

    okx_data["data"].each do |d|
      from_symbol, fee_symbol = d["instId"].split('-')
      qty = (d["notionalUsd"].to_f / d["last"].to_f).round(8)
      next if qty == 0
      t_type = d["posSide"] == "long" || (d["posSide"] == "net" && d["pos"].to_f > 0) ? "sell" : "buy"
      up = get_up(d["instId"], fee_symbol, from_symbol, t_type, 'okx')
      ids.push(up.id)
      up.update(price: d["avgPx"].to_f, qty: qty.abs)

      get_info(up)
    end

    huobi_data["data"].select{|i| i["available"].to_f != 0}.each do |d|
      symbol = d["contract_code"]
      from_symbol, fee_symbol = symbol.split('-')
      price = d["cost_open"].to_f
      size = get_contract_size(symbol).to_f rescue 1
      qty = d["volume"] * size
      t_type = d["direction"] == "buy" ? "sell" : "buy"
      up = get_up(symbol, fee_symbol, from_symbol, t_type, 'huobi')
      ids.push(up.id)
      up.update(price: price, qty: qty.abs)

      get_info(up)
    end

    UserPosition.where(user_id: nil).where.not(id: ids).each do |up|
      if up.binance?
        d = binance_data["positions"].select{|i| i["symbol"] == up.origin_symbol}.first
        t_type = d["positionAmt"].to_f > 0 ? "sell" : "buy" rescue nil
        if d && up.trade_type == t_type
          up.update(price: d["entryPrice"].to_f, qty: d["positionAmt"].to_f.abs)
        else
          up.update(qty: 0)
        end
      else
        up.update(qty: 0)
      end

      get_info(up)
    end

    GetAddingPositionsService.update_current_price
    $redis.set("get_user_positions_refresh_time", Time.now)
  end

  def get_contract_size(symbol)
    url = "https://api.hbdm.vn/linear-swap-api/v1/swap_contract_info?contract_code=#{symbol}"
    response = RestClient.get(url)
    data = JSON.parse(response)
    data["data"][0]["contract_size"]
  end

  def get_info(up)
    UserPositionService.get_info(up)
  end

  def get_up(symbol, fee_symbol, from_symbol, trade_type, source)
    UserPosition.where(user_id: nil, origin_symbol: symbol, fee_symbol: fee_symbol, from_symbol: from_symbol, trade_type: trade_type, source: source).first_or_create
  end
end
