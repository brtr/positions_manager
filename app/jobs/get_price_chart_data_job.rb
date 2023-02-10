require 'rest-client'

class GetPriceChartDataJob < ApplicationJob
  queue_as :daily_job

  def perform(from_date = nil, to_date = Date.yesterday)
    from_date ||= to_date - 1.month
    url = ENV['COIN_ELITE_URL'] + "/api/coins/history_price?symbol=btc&from_date=#{from_date}&to_date=#{to_date}"
    response = RestClient.get(url)
    btc_data = JSON.parse(response.body)

    position_data = {}
    (from_date..to_date).each do |date|
      position_data[date.to_s] = GetAddingPositionsService.execute(date + 1.day, date, true)
    end

    result = {}
    btc_data["result"].each do |date, price|
      result[date] = { btc_price: price, position_amount: position_data[date].to_f }
    end

    $redis.set("monthly_chart_data", result.to_json)
  end
end
