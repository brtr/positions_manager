require 'rest-client'

class GetPositionsSummarySnapshotJob < ApplicationJob
  queue_as :daily_job

  def perform(date = Date.today)
    GetPositionsSummarySnapshotsService.execute(date)
  end
end
