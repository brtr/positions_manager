class SyncFutures24hrTickerJob < ApplicationJob
  queue_as :daily_job

  def perform
    SyncFuturesTickerService.get_24hr_tickers
    GetMarketDataJob.perform_later
  end
end