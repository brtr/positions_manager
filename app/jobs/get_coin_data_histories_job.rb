class GetCoinDataHistoriesJob < ApplicationJob
  queue_as :daily_job

  def perform(date: Date.today)
    UserPosition.available.where(user_id: nil, source: 'binance').each do |up|
      generate_history(up, date)
    end

    ForceGcJob.perform_later
  end

  def generate_history(up, date)
    data = GetBinanceTradingDataService.execute(up.origin_symbol)
    h = CoinDataHistory.where(symbol: up.origin_symbol, event_date: date, source: 'binance').first_or_initialize
    h.update(
      open_interest: data['open_interest'],
      top_long_short_account_ratio: data['top_long_short_account_ratio'],
      top_long_short_position_ratio: data['top_long_short_position_ratio'],
      global_long_short_account_ratio: data['global_long_short_account_ratio'],
      taker_long_short_ratio: data['taker_long_short_ratio']
    )
  end
end
