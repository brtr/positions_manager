class GetPriceChartDataService
  class << self
    def execute(durations = 1)
      to_date = Date.yesterday
      from_date = durations.to_i == 3 ? to_date - 3.months : to_date - 1.month
      url = ENV['COIN_ELITE_URL'] + "/api/coins/history_price_by_symbol?symbol=btc&from_date=#{from_date}&to_date=#{to_date}"
      response = RestClient.get(url)
      btc_data = JSON.parse(response.body)

      position_data = {}
      AddingPositionsHistory.where(event_date: (from_date..to_date)).order(event_date: :asc).group_by(&:event_date)
                            .map{|date, data| position_data[date.to_s] = data.sum(&:amount)}

      revenue_data = {}
      SnapshotInfo.where(source_type: 'synced', user_id: nil, event_date: (from_date..to_date)).order(event_date: :asc)
                  .map{|info| revenue_data[info.event_date.to_s] = info.snapshot_positions.total_summary[:total_revenue]}

      result = {}
      btc_data["result"].each do |date, price|
        result[date] = { btc_price: price, position_amount: position_data[date].to_f, revenue_data: revenue_data[date].to_f }
      end

      $redis.set("monthly_chart_data", result.to_json)
    end
  end
end