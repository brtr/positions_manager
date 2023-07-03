class ExportPositionsHoldingDurationsService
  class << self
    def execute
      ups = UserPosition.where(user_id: nil).available
      snapshots = SnapshotPosition.joins(:snapshot_info).where(snapshot_info: {user_id: nil})
      histories = AddingPositionsHistory.where('current_price is not null and (amount > ? or amount < ?)', 1, -1)

      result = []
      ups.each do |up|
        data = snapshots.select{|s| s.origin_symbol == up.origin_symbol && s.trade_type == up.trade_type && s.source == up.source}.sort_by(&:event_date)
        target = data.find { |d| d.roi.to_f >= 0.5 }
        if target.present?
          duration = get_average_holding_duration(histories.select{|h| h.event_date <= target.event_date && h.origin_symbol == up.origin_symbol && h.trade_type == up.trade_type && h.source == up.source})
          result.push({date: target.event_date, symbol: up.origin_symbol, trade_type: up.trade_type, duration: duration, roi: (target.roi * 100).round(3)})
        end
      end
      result

      file = "合约币种平均持仓时间.csv"
      CSV.open(file, "w") do |writer|
        writer << ['快照时间', '币种', '交易方向', '持仓时间', 'ROI']
        result.each do |h|
          writer << [h[:date], h[:symbol], h[:trade_type], h[:duration], "#{h[:roi]}%"]
        end
      end
    end

    def get_average_holding_duration(data)
      duration = data.blank? ? 0 : data.sum(&:holding_duration) / data.count
      ActionController::Base.helpers.distance_of_time_in_words(duration, 0, { include_seconds: false, accumulate_on: :days })
    end
  end
end