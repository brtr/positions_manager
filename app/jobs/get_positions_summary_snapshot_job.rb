require 'rest-client'

class GetPositionsSummarySnapshotJob < ApplicationJob
  queue_as :daily_job

  def perform(date = Date.yesterday)
    GetPositionsSummarySnapshotsService.execute(date)
    ForceGcJob.perform_later
  end
end
