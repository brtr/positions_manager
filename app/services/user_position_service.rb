class UserPositionService
  class << self
    def get_info(up, user_id=nil)
      get_current_price(up)
      get_margin_ratio(up)
      get_last_revenue(up, user_id)
    end

    def get_current_price(up)
      # current price
      if up.binance?
        url = ENV['BINANCE_FUTURES_URL'] + "/fapi/v1/ticker/price?symbol=#{up.origin_symbol}"
        response = RestClient.get(url)
        data = JSON.parse(response)
        current_price = data["price"].to_f if data && data["price"]
      elsif up.huobi?
        url = ENV['HUOBI_FUTURES_URL'] + "/linear-swap-ex/market/trade?contract_code=#{up.origin_symbol}"
        response = RestClient.get(url)
        data = JSON.parse(response)
        current_price = data["tick"]["data"][0]["price"].to_f if data && data["tick"]
      else
        url = ENV['OKX_FUTURES_URL'] + "/api/v5/market/ticker?instId=#{up.origin_symbol}"
        response = RestClient.get(url)
        data = JSON.parse(response)["data"][0]
        current_price = data["last"].to_f if data && data["last"]
      end
      up.update(current_price: current_price)
    end
  
    def get_margin_ratio(up)
      # margin ratio
      url = ENV['COIN_ELITE_URL'] + "/api/user_positions/margin_ratio?symbol=#{up.from_symbol}&trade_type=#{up.trade_type}&current_price=#{up.current_price}"
      response = RestClient.get(url)
      data = JSON.parse(response)
  
      up.update(margin_ratio: data["margin_ratio"])
    end
  
    def get_last_revenue(up, user_id=nil)
      snapshot = SnapshotPosition.joins(:snapshot_info).where(origin_symbol: up.origin_symbol, trade_type: up.trade_type, source: up.source, snapshot_info: {user_id: user_id, event_date: Date.yesterday}).take
      up.update(last_revenue: snapshot.revenue) if snapshot
    end
  end
end