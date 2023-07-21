class SyncFutures24hrTickerJob < ApplicationJob
  queue_as :daily_job

  def perform(bottom_select=0, top_select=0, duration=12, data_type='all')
    SyncFuturesTickerService.get_24hr_tickers(bottom_select, top_select, duration, data_type)
    GetMarketDataJob.perform_later
  end
end