class GetFundingFeeHistoriesJob < ApplicationJob
  queue_as :daily_job

  def perform
    date = Date.yesterday
    UserPosition.available.where(user_id: nil).each do |up|
      generate_history(up, date)
    end

    UserSyncedPosition.available.each do |up|
      generate_history(up, date)
    end

    ForceGcJob.perform_later
  end

  def generate_history(up, date)
    rate = get_rate(up.origin_symbol, up.source, date)
    ffh = FundingFeeHistory.where(origin_symbol: up.origin_symbol, event_date: date, source: up.source, user_id: up.user_id).first_or_initialize
    ffh.update(rate: rate, amount: rate * up.amount * 3)
  end

  def get_rate(symbol, source, date)
    if source == 'binance'
      rate_list = BinanceFuturesService.new.get_funding_rate(symbol, date.strftime('%Q'))
      daily_rates = rate_list.select{|r| Time.at(r['fundingTime']/1000).to_date == date}
      daily_rates.sum{|r| r['fundingRate'].to_f} / 3
    elsif source == 'okx'
      rate_list = OkxFuturesService.new.get_funding_rate(symbol, date.strftime('%Q'))
      daily_rates = rate_list['data'].select{|r| Time.at(r['fundingTime'].to_f/1000).to_date == date}
      daily_rates.sum{|r| r['realizedRate'].to_f} / 3
    else
      0
    end
  end
end
