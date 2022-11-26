class GetSyncedUserPositionsJob < ApplicationJob
  queue_as :daily_job

  def perform
    User.where.not(api_key: nil, secret_key: nil).each do |u|
      GetPrivateUserPositionsJob.perform_later(u.id)
    end
  end
end
