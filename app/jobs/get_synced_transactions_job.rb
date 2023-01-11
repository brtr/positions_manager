class GetSyncedTransactionsJob < ApplicationJob
  queue_as :daily_job

  def perform
    UserPosition.where(user_id: nil, source: 'binance').each do |up|
      snapshot = up.last_snapshot
      next unless snapshot
      GetBinanceFuturesTransactionsJob.perform_later(up.origin_symbol) unless snapshot.qty == up.qty
    end
  end
end
