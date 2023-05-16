class GenerateUserPublicPositionsSnapshotsJob < ApplicationJob
  queue_as :daily_job

  def perform(date: Date.today)
    snapshot_info = SnapshotInfo.synced.where(event_date: date, user_id: nil).first_or_create
    generate_snapshot(snapshot_info)
    GetSnapshotInfoSummaryJob.perform_later(snapshot_info, date, true)
  end

  def generate_snapshot(snapshot_info)
    SnapshotPosition.transaction do
      histories = UserPosition.where("qty != ?", 0)
      histories = snapshot_info.user_id ? histories.where(user_id: snapshot_info.user_id) : histories.where(user_id: nil)
      histories.each do |up|
        snap_shot = snapshot_info.snapshot_positions.where(origin_symbol: up.origin_symbol, trade_type: up.trade_type, event_date: snapshot_info.event_date, source: up.source).first_or_create
        snap_shot.update(from_symbol: up.from_symbol, fee_symbol: up.fee_symbol, qty: up.qty, price: up.price, last_revenue: up.last_revenue,
                        amount: up.amount, estimate_price: up.current_price, revenue: up.revenue, margin_ratio: up.margin_ratio, level: up.level)
      end
    end
  end
end
