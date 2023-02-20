class GetAddingPositionsHistoriesJob < ApplicationJob
  queue_as :daily_job

  def perform
    to_date = Date.current
    GetAddingPositionsService.execute(to_date - 1.day, to_date)
  end
end
