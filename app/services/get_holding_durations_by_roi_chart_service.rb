class GetHoldingDurationsByRoiChartService
  class << self
    def execute(gap=5)
      symbols = UserPosition.where(user_id: nil).pluck(:origin_symbol)
      records = []

      SnapshotPosition.joins(:snapshot_info).where(origin_symbol: symbols, snapshot_info: {user_id: nil}).order(event_date: :asc).group_by(&:origin_symbol).each do |symbol, data|
        open_date = data.first.event_date
        roi_30 = data.select{|x| x.roi >= 0.3 }.first
        roi_40 = data.select{|x| x.roi >= 0.4 }.first

        if roi_30.present?
          records.push({
            symbol: symbol,
            roi_30: (roi_30.event_date - open_date).to_i,
            roi_40: ((roi_40.event_date - open_date).to_i rescue 0)
          })
        end
      end

      max_duration = records.map{|x| [x[:roi_30], x[:roi_40]]}.flatten.max
      ranges = 0.step(max_duration + gap, gap).each_cons(2).map { |s, e| Range.new(s, e, true) }

      data = {}
      ranges.each do |r|
        data[r] = {
          roi_30: records.count{|x| r.cover? x[:roi_30]},
          roi_40: records.count{|x| r.cover? x[:roi_40]}
        }
      end
      data
    end
  end
end