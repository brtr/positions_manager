class SyncFutures24hrTickerJob < ApplicationJob
  queue_as :daily_job

  def perform(bottom_select=0, top_select=0)
    SyncFuturesTickerService.get_24hr_tickers(bottom_select, top_select)
    GetMarketDataJob.perform_later
  end
end