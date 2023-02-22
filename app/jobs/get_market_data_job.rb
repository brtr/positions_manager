class GetMarketDataJob < ApplicationJob
  queue_as :daily_job

  def perform
    binance_24hr_tickers = BinanceFuturesService.new.get_24hr_tickers
    total_count = binance_24hr_tickers.count
    risen = binance_24hr_tickers.count{ |d| d["priceChange"].to_f > 0}
    fallen = binance_24hr_tickers.count{ |d| d["priceChange"].to_f < 0}

    result = {
      risen: risen,
      risen_ratio: ((risen.to_f / total_count) * 100).round(3),
      fallen: fallen,
      fallen_ratio: ((fallen.to_f / total_count) * 100).round(3)
    }

    $redis.set('daily_market_data', result.to_json)
  end
end
