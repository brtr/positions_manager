class GetAddingPositionsService
  class << self
    def execute(from_date, to_date)
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
        if h.is_a?(UserPosition)
          current_price = h.current_price
          event_date = Date.current
        else
          current_price = UserPosition.where(user_id: nil, origin_symbol: h.origin_symbol, trade_type: h.trade_type, source: h.source).take&.current_price || h.estimate_price
          event_date = h.event_date
        end
        last_amount = margin_qty * current_price
        revenue = snapshot.nil? ? h.revenue : h.trade_type == 'sell' ? last_amount - margin_amount : margin_amount - last_amount
        price = margin_amount / margin_qty
        aph = AddingPositionsHistory.where(event_date: event_date, origin_symbol: h.origin_symbol, from_symbol: h.from_symbol,
                                          fee_symbol: h.fee_symbol, trade_type: h.trade_type, source: h.source).first_or_create
        aph.update(price: price.round(3), current_price: current_price.round(3), qty: margin_qty.round(3),
                   revenue: revenue.round(3), amount: margin_amount, roi: ((revenue / margin_amount) * 100).round(3),
                   amount_ratio: ((margin_amount / h.amount) * 100).round(3))
      end
    end

    def update_current_price
      AddingPositionsHistory.all.group_by{|aph| [aph.origin_symbol, aph.trade_type, aph.source]}.each do |key, value|
        current_price = UserPosition.where(user_id: nil, origin_symbol: key[0], trade_type: key[1], source: key[2]).take&.current_price
        AddingPositionsHistory.where(id: value.map(&:id)).each do |aph|
          last_amount = aph.qty * current_price
          revenue = aph.trade_type == 'sell' ? last_amount - aph.amount : aph.amount - last_amount
          aph.update(current_price: current_price, revenue: revenue, roi: ((revenue / aph.amount) * 100).round(3))
        end unless current_price.nil?
      end
    end
  end
end