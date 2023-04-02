require 'rest-client'

class GetPriceChartDataJob < ApplicationJob
  queue_as :daily_job

  def perform
    GetPriceChartDataService.execute

    ForceGcJob.perform_later
  end
end
