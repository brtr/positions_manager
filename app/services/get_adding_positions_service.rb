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
        margin_qty = (h.qty - snapshot&.qty.to_f).round(3)
        margin_amount = (h.amount - snapshot&.amount.to_f).round(3)
        next if margin_qty.zero? || margin_amount.zero?
        if h.is_a?(UserPosition)
          current_price = h.current_price
          event_date = Date.current
        else
          if margin_qty > 0
            current_price = UserPosition.where(user_id: nil, origin_symbol: h.origin_symbol, trade_type: h.trade_type, source: h.source).take&.current_price || h.estimate_price
          elsif margin_qty < 0
            current_price = get_history_price(h.from_symbol.downcase, h.event_date)
          end
          event_date = h.event_date
        end
        price = margin_amount / margin_qty.to_f
        aph = AddingPositionsHistory.where(event_date: event_date, origin_symbol: h.origin_symbol, from_symbol: h.from_symbol,
                                          fee_symbol: h.fee_symbol, trade_type: h.trade_type, source: h.source).first_or_create
        aph.update(price: price, current_price: current_price, qty: margin_qty, amount: margin_amount)
      end
    end

    def update_current_price
      AddingPositionsHistory.all.group_by{|aph| [aph.origin_symbol, aph.trade_type, aph.source]}.each do |key, value|
        current_price = UserPosition.where(user_id: nil, origin_symbol: key[0], trade_type: key[1], source: key[2]).take&.current_price
        AddingPositionsHistory.where('id in (?) and qty > 0', value.map(&:id)).update_all(current_price: current_price) unless current_price.nil?
      end
    end

    def get_history_price(symbol, event_date)
      url = ENV['COIN_ELITE_URL'] + "/api/coins/history_price?symbol=#{symbol}&from_date=#{event_date}&to_date=#{event_date}"
      response = RestClient.get(url)
      data = JSON.parse(response.body)
      data['result'].values[0].to_f rescue nil
    end
  end
end