class GetPrivateUserPositionsInfoJob < ApplicationJob
  queue_as :daily_job

  def perform(user_id)
    UserPosition.where(user_id: user_id).each do |up|
      UserPositionService.get_info(up, user_id, true)
    end

    ForceGcJob.perform_later
    $redis.set("get_user_#{user_id}_positions_refresh_time", Time.now)
  end
end
