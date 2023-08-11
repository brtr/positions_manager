class GetHoldingDurationsByRoiChartService
  class << self
    def execute(gap: 5, min_amount: nil, max_amount: nil, average: false)
      redis_key = "holding_duration_chart_data_gap_#{gap.to_i}_min_amount_#{min_amount.to_i}_max_amount_#{max_amount.to_i}_average_#{average.to_s}"
      data = $redis.get(redis_key) rescue nil
      if data.nil?
        ups = UserPosition.available.where(user_id: nil)
        ups = ups.select{|up| up.amount >= min_amount} if min_amount.present?
        ups = ups.select{|up| up.amount <= max_amount} if max_amount.present?
        symbols = ups.map(&:origin_symbol)
        records = []

        SnapshotPosition.joins(:snapshot_info).where(origin_symbol: symbols, snapshot_info: {user_id: nil}).order(event_date: :asc).group_by(&:origin_symbol).each do |symbol, data|
          open_date = data.first.event_date
          roi_30 = data.select{|x| x.roi >= 0.3 }.first
          roi_40 = data.select{|x| x.roi >= 0.4 }.first
          up = ups.select{|x| x.origin_symbol == symbol}.first

          records.push({
            symbol: symbol,
            duration: up.average_durations.to_i / 86400,
            roi: up.roi,
            roi_30: ((roi_30.event_date - open_date).to_i rescue 0),
            roi_40: ((roi_40.event_date - open_date).to_i rescue 0)
          })
        end

        max_duration = records.map{|x| average ? x[:duration] : [x[:roi_30], x[:roi_40]]}.flatten.max
        ranges = 0.step(max_duration + gap, gap).each_cons(2).map { |s, e| Range.new(s, e, true) }

        data = {}
        ranges.each do |r|
          total_durations = records.select{|x| r.cover?(x[:duration]) && x[:duration] > 0}
          data[r] = {
            roi_30: records.count{|x| r.cover?(x[:roi_30]) && x[:roi_30] > 0},
            roi_40: records.count{|x| r.cover?(x[:roi_40]) && x[:roi_40] > 0},
            range: r,
            average_roi: total_durations.any? ? (total_durations.sum{|d| d[:roi].to_f} / total_durations.count).to_f : 0
          }
        end
        data = data.to_json

        $redis.set(redis_key, data, ex: 5.hours)
      end

      JSON.parse(data).with_indifferent_access
    end

    def execute_by_symbol(up_id, gap: 5, average: true)
      up = UserPosition.find(up_id)
      redis_key = "holding_duration_chart_#{up_id}_data_gap_#{gap.to_i}_average_#{average.to_s}"
      data = $redis.get(redis_key) rescue nil
      if data.nil?
        snapsohts = SnapshotPosition.joins(:snapshot_info).where(origin_symbol: up.origin_symbol, trade_type: up.trade_type, source: up.source, snapshot_info: {user_id: nil}).order(event_date: :asc)

        record = {
          open_date: snapsohts.first.event_date,
          data: snapsohts,
          duration: up.average_durations.to_i / 86400
        }

        ranges = 0.step(record[:duration].to_i + gap, gap).each_cons(2).map { |s, e| Range.new(s, e, true) }

        data = {}
        if record.present?
          ranges.map do |r|
            total_durations = record[:data].select{ |x| r.cover?((x.event_date - record[:open_date]).to_i) }
            data[r] = {
              range: r,
              average_roi: total_durations.any? ? (((total_durations.sum{|d| d.roi.to_f} / total_durations.count).to_f) * 100).round(3) : 0
            }
          end
        end
        data = data.to_json

        $redis.set(redis_key, data, ex: 5.hours)
      end

      JSON.parse(data).with_indifferent_access
    end
  end
end