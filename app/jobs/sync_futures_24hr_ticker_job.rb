class SyncFutures24hrTickerJob < ApplicationJob
  queue_as :daily_job

  def perform
    SyncFuturesTickerService.get_24hr_tickers
  end
end