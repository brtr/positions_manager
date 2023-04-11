class SyncCoinRankingJob < ApplicationJob
  queue_as :daily_job

  def perform
    symbols = UserPosition.pluck(:from_symbol)
    symbols += get_tickers_symbols
    url = ENV['COIN_ELITE_URL'] + "/api/coins/rankings?symbols=" + Base64.encode64(symbols.uniq.map(&:downcase).join(','))
    response = RestClient.get(url)
    data = JSON.parse(response.body)['result'] rescue []

    CoinRanking.transaction do
      data.each do |d|
        cr = CoinRanking.where(symbol: d[0]).first_or_initialize
        cr.update(rank: d[1])
      end
    end
  end

  def get_tickers_symbols
    JSON.parse($redis.get("get_24hr_tickers")).map do |k|
      SyncFuturesTickerService.fetch_symbol k["symbol"]
    end rescue []
  end
end