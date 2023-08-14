class GetAddingPositionsHistoriesJob < ApplicationJob
  queue_as :daily_job

  def perform(symbol: nil)
    GetSyncedTransactionsJob.perform_now
    GetRecentlyAddingPositionsJob.perform_now(symbol: symbol)

    ForceGcJob.perform_later
  end
end
