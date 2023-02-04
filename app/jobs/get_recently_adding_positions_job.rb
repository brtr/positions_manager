class GetRecentlyAddingPositionsJob < ApplicationJob
  queue_as :daily_job

  def perform
    $redis.del('recently_adding_positions')
    result = []

    snapshot_records = SnapshotPosition.joins(:snapshot_info).where(snapshot_info: {user_id: nil, event_date: Date.today - 1.week})
    UserPosition.where(user_id: nil).available.each do |h|
      snapshot = snapshot_records.select{|s| s.origin_symbol == h.origin_symbol && s.trade_type == h.trade_type && s.source == h.source}.first
      margin_qty = h.qty - snapshot&.qty.to_f
      margin_amount = (h.amount - snapshot&.amount.to_f).round(3)
      next if margin_amount < 1
      last_amount = margin_qty * h.current_price
      revenue = snapshot.nil? ? h.revenue : h.trade_type == 'sell' ? last_amount - margin_amount : margin_amount - last_amount
      price = margin_amount / margin_qty
      result.push({
        symbol: h.origin_symbol,
        source: h.source,
        price: price.round(3),
        current_price: h.current_price.round(3),
        qty: margin_qty.round(3),
        revenue: revenue.round(3),
        amount: margin_amount,
        roi: ((revenue / margin_amount) * 100).round(3),
        amount_ratio: ((margin_amount / h.amount) * 100).round(3)
      })
    end

    $redis.set('recently_adding_positions', result.to_json) if result.any?
  end
end
