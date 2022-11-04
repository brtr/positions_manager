class GetPublicUserPositionsJob < ApplicationJob
  queue_as :daily_job

  def perform
    binance_data = BinanceFuturesService.get_positions
    okx_data = OkxFuturesService.get_positions
    huobi_data = HuobiFuturesService.get_positions
    ids = []

    binance_data["positions"].select{|i| i["positionAmt"].to_f != 0}.each do |d|
      fee_symbol = d["symbol"].include?("USDT") ? "USDT" : "BUSD"
      from_symbol = d["symbol"].split(fee_symbol)[0]
      qty = d["positionAmt"].to_f
      t_type = qty > 0 ? "sell" : "buy"
      up = UserPosition.where(origin_symbol: d["symbol"], fee_symbol: fee_symbol, from_symbol: from_symbol, trade_type: t_type, source: "binance").first_or_create
      ids.push(up.id)
      up.update(price: d["entryPrice"].to_f, qty: qty.abs)

      get_info(up)
    end

    okx_data["data"].select{|i| i["pos"].to_f != 0}.each do |d|
      from_symbol, fee_symbol = d["instId"].split('-')
      qty = (d["notionalUsd"].to_f / d["last"].to_f).round(0)
      t_type = d["posSide"] == "long" || (d["posSide"] == "net" && d["pos"].to_f > 0) ? "sell" : "buy"
      up = UserPosition.where(origin_symbol: d["instId"], fee_symbol: fee_symbol, from_symbol: from_symbol, trade_type: t_type, source: "okx").first_or_create
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
      up = UserPosition.where(origin_symbol: symbol, fee_symbol: fee_symbol, from_symbol: from_symbol, trade_type: t_type, source: "huobi").first_or_create
      ids.push(up.id)
      up.update(price: price, qty: qty.abs)

      get_info(up)
    end

    UserPosition.where(user_id: nil).where.not(id: ids).each do |up|
      if up.binance?
        d = binance_data["positions"].select{|i| i["symbol"] == up.origin_symbol}.first
        up.update(price: d["entryPrice"].to_f, qty: d["positionAmt"].to_f.abs) if d
      else
        up.update(qty: 0)
      end

      get_info(up)
    end

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
end
