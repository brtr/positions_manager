class GetAddingPositionsService
  class << self
    def execute(from_date, to_date, get_summary = false)
      $redis.del('filters_adding_positions')
      result = []

      from_date_records = SnapshotPosition.joins(:snapshot_info).where(snapshot_info: {user_id: nil, event_date: from_date})
      to_date_records = if to_date.to_s == Date.today.to_s
                          UserPosition.where(user_id: nil)
                        else
                          SnapshotPosition.joins(:snapshot_info).where(snapshot_info: {user_id: nil, event_date: to_date})
                        end

      to_date_records.available.each do |h|
        snapshot = from_date_records.select{|s| s.origin_symbol == h.origin_symbol && s.trade_type == h.trade_type && s.source == h.source}.first
        margin_qty = h.qty - snapshot&.qty.to_f
        margin_amount = (h.amount - snapshot&.amount.to_f).round(3)
        next if margin_amount < 1
        current_price = UserPosition.where(user_id: nil, origin_symbol: h.origin_symbol, trade_type: h.trade_type, source: h.source).take&.current_price || h.estimate_price
        last_amount = margin_qty * current_price
        revenue = snapshot.nil? ? h.revenue : h.trade_type == 'sell' ? last_amount - margin_amount : margin_amount - last_amount
        price = margin_amount / margin_qty
        result.push({
          symbol: h.origin_symbol,
          source: h.source,
          price: price.round(3),
          current_price: current_price.round(3),
          qty: margin_qty.round(3),
          revenue: revenue.round(3),
          amount: margin_amount,
          roi: ((revenue / margin_amount) * 100).round(3),
          amount_ratio: ((margin_amount / h.amount) * 100).round(3)
        })
      end

      if get_summary
        result.sum{|d| d[:amount]}
      else
        $redis.set('filters_adding_positions', result.to_json) if result.any?
      end
    end
  end
end