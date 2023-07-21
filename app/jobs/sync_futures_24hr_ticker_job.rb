class SyncFutures24hrTickerJob < ApplicationJob
  queue_as :daily_job

  def perform(bottom_select=0, top_select=0, duration=12, data_type='all')
    $redis.set('bottom_select_ranking', bottom_select) if bottom_select.present?
    $redis.set('top_select_ranking', top_select) if top_select.present?
    $redis.set('top_select_duration', duration) if duration.present?
    SyncFuturesTickerService.get_24hr_tickers(bottom_select, top_select, duration, data_type)
    GetMarketDataJob.perform_later

    ForceGcJob.perform_later
  end
end