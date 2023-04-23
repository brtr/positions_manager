class GetPrivateUserPositionsJob < ApplicationJob
  queue_as :daily_job

  def perform(user_id)
    binance_data = BinanceFuturesService.new(user_id: user_id).get_positions
    okx_data = OkxFuturesService.new(user_id: user_id).get_positions
    ids = []

    binance_data["positions"].select{|i| i["positionAmt"].to_f != 0}.each do |d|
      fee_symbol = d["symbol"].include?("USDT") ? "USDT" : "BUSD"
      from_symbol = d["symbol"].split(fee_symbol)[0]
      qty = d["positionAmt"].to_f
      t_type = qty > 0 ? "sell" : "buy"
      up = UserSyncedPosition.where(user_id: user_id, origin_symbol: d["symbol"], fee_symbol: fee_symbol, from_symbol: from_symbol, trade_type: t_type, source: 'binance').first_or_create
      ids.push(up.id)
      up.update(price: d["entryPrice"].to_f, qty: qty.abs)

      get_info(up, user_id)
    end

    unless okx_data["data"].nil?
      okx_data["data"].each do |d|
        from_symbol, fee_symbol = d["instId"].split('-')
        qty = (d["notionalUsd"].to_f / d["last"].to_f).round(8)
        next if qty == 0
        t_type = d["posSide"] == "long" || (d["posSide"] == "net" && d["pos"].to_f > 0) ? "sell" : "buy"
        up = UserSyncedPosition.where(user_id: user_id, origin_symbol: d["instId"], fee_symbol: fee_symbol, from_symbol: from_symbol, trade_type: t_type, source: 'okx').first_or_create
        ids.push(up.id)
        up.update(price: d["avgPx"].to_f, qty: qty.abs)

        get_info(up, user_id)
      end
    end

    UserSyncedPosition.where(user_id: user_id).where.not(id: ids).each do |up|
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

      get_info(up, user_id)
    end

    ForceGcJob.perform_later
    $redis.set("get_user_#{user_id}_synced_positions_refresh_time", Time.now)
  end

  def get_info(up, user_id)
    UserPositionService.get_info(up, user_id)
  end
end
