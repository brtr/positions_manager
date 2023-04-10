class SyncCoinRankingJob < ApplicationJob
  queue_as :daily_job

  def perform
    symbols = UserPosition.pluck(:from_symbol).uniq.map(&:downcase)
    url = ENV['COIN_ELITE_URL'] + "/api/coins/rankings?symbols=" + Base64.encode64(symbols.join(','))
    response = RestClient.get(url)
    data = JSON.parse(response.body)['result'] rescue []

    CoinRanking.transaction do
      data.each do |d|
        cr = CoinRanking.where(symbol: d[0]).first_or_initialize
        cr.update(rank: d[1])
      end
    end
  end
end