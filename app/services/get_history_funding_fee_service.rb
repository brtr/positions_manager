class GetHistoryFundingFeeService
  class << self
    def execute
      snapshots = SnapshotPosition.joins(:snapshot_info).where(snapshot_info: {source_type: 'synced', user_id: nil})
      snapshots.order(event_date: :asc).group_by{|snapshot| [snapshot.origin_symbol, snapshot.source]}.each do |snapshot, data|
        rate_list = BinanceFuturesService.new.get_funding_rate(snapshot[0])
        data.pluck(:event_date, :amount).each do |date, amount|
          rate = get_rate(snapshot[0], snapshot[1], date)
          ffh = FundingFeeHistory.where(origin_symbol: snapshot[0], event_date: date, source: snapshot[1]).first_or_initialize
          ffh.update(rate: rate, amount: rate * amount * 3)
        end
      end
    end

    def get_rate(symbol, source, date)
      if source == 'binance'
        rate_list = BinanceFuturesService.new.get_funding_rate(symbol)
        daily_rates = rate_list.select{|r| Time.at(r['fundingTime']/1000).to_date == date}
        daily_rates.sum{|r| r['fundingRate'].to_f} / 3
      elsif source == 'okx'
        rate_list = OkxFuturesService.get_funding_rate(symbol)
        daily_rates = rate_list['data'].select{|r| Time.at(r['fundingTime'].to_f/1000).to_date == date}
        daily_rates.sum{|r| r['realizedRate'].to_f} / 3
      else
        0
      end
    end
  end
end