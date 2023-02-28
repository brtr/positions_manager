class GetPositionsChartDataService
  class << self
    def execute(origin_symbol, source, trade_type)
      to_date = Date.yesterday
      from_date = to_date - 1.month
      symbol = get_symbol(origin_symbol).downcase
      url = ENV['COIN_ELITE_URL'] + "/api/coins/history_price?symbol=#{symbol}&from_date=#{from_date}&to_date=#{to_date}"
      response = RestClient.get(url)
      price_data = JSON.parse(response.body)

      position_data = {}
      AddingPositionsHistory.where(origin_symbol: origin_symbol, event_date: (from_date..to_date), source: source).order(event_date: :asc).group_by(&:event_date)
                            .map{|date, data| position_data[date.to_s] = data.sum(&:amount)}

      position = UserPosition.find_by(origin_symbol: origin_symbol, trade_type: trade_type, source: source)
      qty = position.qty.round(3) rescue 0
      price = position.price.round(3) rescue 0

      result = {}
      price_data["result"].each do |date, daily_price|
        result[date] = { daily_price: daily_price.to_f.round(3), position_amount: position_data[date].to_f.round(3), date: date, qty: qty, price: price }
      end

      $redis.set("#{origin_symbol}_monthly_chart_data", result.to_json)
    end

    def get_symbol(symbol)
      symbol = symbol.split(/-/)[0]
      symbol = symbol.split(/USDT/)[0]
      symbol.split(/BUSD/)[0]
    end
  end
end