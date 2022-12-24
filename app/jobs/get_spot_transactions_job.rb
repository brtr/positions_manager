class GetSpotTransactionsJob < ApplicationJob
  queue_as :daily_job

  def perform
    data = BinanceSpotsService.get_account

    data[:balances].select{|i| i[:free].to_f != 0 || i[:locked].to_f != 0}.each do |i|
      GetSpotTradesJob.perform_later(i[:asset])
    end

    $redis.set("get_spot_transactions_refresh_time", Time.now)
  end
end
