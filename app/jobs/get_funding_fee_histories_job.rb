class GetFundingFeeHistoriesJob < ApplicationJob
  queue_as :daily_job

  def perform(sync_ranking: false)
    if sync_ranking
      result = []
      tickers = JSON.parse($redis.get('get_24hr_tickers')).sort_by{|d| d['priceChangePercent'].to_f}.reverse.first(3) rescue []
      tickers.each do |ticker|
        source = ticker["source"]
        symbol = source == 'okx' ? ticker['instId'] : ticker['symbol']
        result.push({
          symbol: ticker['symbol'],
          rate: get_rate(symbol, source, Date.today, get_latest: true) 
        })
      end

      $redis.set('top_3_symbol_funding_rates', result.to_json)
    else
      date = Date.yesterday
      UserPosition.available.where(user_id: nil).each do |up|
        generate_history(up, date)
      end

      UserSyncedPosition.available.each do |up|
        generate_history(up, date)
      end
    end

    ForceGcJob.perform_later
  end

  def generate_history(up, date)
    rate = get_rate(up.origin_symbol, up.source, date)
    SnapshotPosition.joins(:snapshot_info).where(snapshot_info: { user_id: up.user_id }, origin_symbol: up.origin_symbol, event_date: date, source: up.source).each do |snapshot|
      ffh = FundingFeeHistory.where(origin_symbol: snapshot.origin_symbol, event_date: date, source: snapshot.source, user_id: up.user_id, trade_type: up.trade_type).first_or_initialize
      ffh.update(rate: rate, amount: rate * up.amount * 3, snapshot_position_id: snapshot&.id)
    end
  end

  def get_rate(symbol, source, date, get_latest: false)
    if source == 'binance'
      rate_list = BinanceFuturesService.new.get_funding_rate(symbol, date.strftime('%Q'))
      daily_rates = rate_list.select{|r| Time.at(r['fundingTime']/1000).to_date == date}
      get_latest ? daily_rates.last['fundingRate'].to_f : daily_rates.sum{|r| r['fundingRate'].to_f} / 3
    elsif source == 'okx'
      rate_list = OkxFuturesService.new.get_funding_rate(symbol, date.strftime('%Q'))
      daily_rates = rate_list['data'].select{|r| Time.at(r['fundingTime'].to_f/1000).to_date == date}
      get_latest ? daily_rates.last['realizedRate'].to_f : daily_rates.sum{|r| r['realizedRate'].to_f} / 3
    else
      0
    end
  end
end
