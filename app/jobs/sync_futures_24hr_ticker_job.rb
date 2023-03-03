class SyncFutures24hrTickerJob < ApplicationJob
  queue_as :daily_job

  def perform(rank=0)
    SyncFuturesTickerService.get_24hr_tickers(rank)
    GetMarketDataJob.perform_later
  end
end