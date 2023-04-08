class GetSpotBalanceHistoriesJob < ApplicationJob
  queue_as :daily_job

  def perform(date = Date.today)
    user_ids = User.where('api_key is not null and secret_key is not null').ids
    user_ids.each do |user_id|
      # 生成私人现货账户余额
      execute(date, user_id)
    end

    # 生成公共现货账户余额
    execute(date)

    ForceGcJob.perform_later
  end

  def execute(date, user_id=nil)
    data = BinanceSpotsService.new(user_id: user_id).get_account rescue nil
    return if data.nil?

    SpotBalanceHistory.transaction do
      data[:balances].select{|i| i[:free].to_f != 0 || i[:locked].to_f != 0}.each do |i|
        SpotBalanceHistory.where(user_id: user_id, asset: i[:asset], free: i[:free],
                                 locked: i[:locked], event_date: date, source: 'binance').first_or_create
      end
    end
  end
end
