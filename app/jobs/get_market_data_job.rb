class GetMarketDataJob < ApplicationJob
  queue_as :daily_job
  BTC_SYMBOLS = %w[BTCUSDT BTCBUSD]

  def perform
    binance_24hr_tickers = BinanceFuturesService.new.get_24hr_tickers
    total_count = binance_24hr_tickers.count
    risen = binance_24hr_tickers.count{ |d| d["priceChange"].to_f > 0}
    fallen = binance_24hr_tickers.count{ |d| d["priceChange"].to_f < 0}
    btc = binance_24hr_tickers.select{|d| d["symbol"].in?(BTC_SYMBOLS)}.first

    result = {
      risen: risen,
      risen_ratio: ((risen.to_f / total_count) * 100).round(4),
      fallen: fallen,
      fallen_ratio: ((fallen.to_f / total_count) * 100).round(4),
      btc_change: btc["priceChange"].to_f,
      btc_change_ratio: btc["priceChangePercent"].to_f
    }

    $redis.set('daily_market_data', result.to_json)
  end
end