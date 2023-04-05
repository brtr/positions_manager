class GetUsersSpotTransactionsJob < ApplicationJob
  queue_as :daily_job

  def perform(user_id=nil)
    if user_id
      execute(user_id)
    else
      user_ids = User.where('api_key is not null and secret_key is not null').ids
      user_ids.each do |user_id|
        execute(user_id)
      end
    end

    ForceGcJob.perform_later
  end

  def execute(user_id)
    data = BinanceSpotsService.new(user_id: user_id).get_account rescue nil
    return if data.nil?

    data[:balances].select{|i| i[:free].to_f != 0 || i[:locked].to_f != 0}.each do |i|
      GetSpotTradesJob.perform_later(i[:asset], user_id)
    end
  end
end
