class GenerateUserSpotBalanceSnapshotsJob < ApplicationJob
  queue_as :daily_job

  def perform(date: Date.today)
    user_ids = UserSpotBalance.where("qty != ?", 0).pluck(:user_id).compact.uniq
    user_ids.each do |user_id|
      snapshot_info = SpotBalanceSnapshotInfo.where(event_date: date, user_id: user_id).first_or_create
      generate_snapshot(snapshot_info)
    end
  end

  def generate_snapshot(snapshot_info)
    SpotBalanceSnapshotRecord.transaction do
      usbs = UserSpotBalance.where("user_id = ? and qty != ?", snapshot_info.user_id, 0)
      usbs.each do |h|
        snap_shot = snapshot_info.spot_balance_snapshot_records.where(origin_symbol: h.origin_symbol, event_date: snapshot_info.event_date, source: h.source).first_or_initialize
        snap_shot.update(from_symbol: h.from_symbol, to_symbol: h.to_symbol, qty: h.qty, price: h.price,
                         amount: h.amount, estimate_price: h.current_price, revenue: h.revenue)
      end
    end
  end
end
