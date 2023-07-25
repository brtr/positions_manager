class GetAddingPositionsHistoriesJob < ApplicationJob
  queue_as :daily_job

  def perform
    GetSyncedTransactionsJob.perform_now
    GetRecentlyAddingPositionsJob.perform_now

    ForceGcJob.perform_later
  end
end
