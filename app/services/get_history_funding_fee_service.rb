class GetHistoryFundingFeeService
  class << self
    def execute
      snapshots = SnapshotPosition.joins(:snapshot_info).where(snapshot_info: {source_type: 'synced', event_date: [Date.today.at_beginning_of_year..Date.today]})
      snapshots.order(event_date: :asc).group_by{|snapshot| [snapshot.origin_symbol, snapshot.source, snapshot.snapshot_info.user_id]}.each do |snapshot, data|
        data.pluck(:event_date, :amount).each do |date, amount|
          rate = get_rate(snapshot[0], snapshot[1], date)
          next if rate.nil?
          ffh = FundingFeeHistory.where(origin_symbol: snapshot[0], event_date: date, user_id: snapshot[2], source: snapshot[1]).first_or_initialize
          ffh.update(rate: rate, amount: rate * amount * 3)
        end
      end
    end

    def get_rate(symbol, source, date)
      if source == 'binance'
        rate_list = BinanceFuturesService.new.get_funding_rate(symbol)
        return if rate_list.blank?
        daily_rates = rate_list.select{|r| Time.at(r['fundingTime']/1000).to_date == date}
        daily_rates.sum{|r| r['fundingRate'].to_f} / 3
      elsif source == 'okx'
        rate_list = OkxFuturesService.new.get_funding_rate(symbol, (date - 1.day).strftime('%Q'))
        return if rate_list['data'].nil?
        daily_rates = rate_list['data'].select{|r| Time.at(r['fundingTime'].to_f/1000).to_date == date}
        daily_rates.sum{|r| r['realizedRate'].to_f} / 3
      else
        0
      end
    end
  end
end