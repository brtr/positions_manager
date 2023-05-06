class GeneratePublicSpotBalanceSnapshotsJob < ApplicationJob
  queue_as :daily_job

  def perform(date: Date.today)
    snapshot_info = SpotBalanceSnapshotInfo.where(event_date: date, user_id: nil).first_or_create
    generate_snapshot(snapshot_info)
  end

  def generate_snapshot(snapshot_info)
    SpotBalanceSnapshotRecord.transaction do
      histories = UserSpotBalance.where("user_id = ? and qty != ?", nil, 0)
      histories.each do |h|
        snap_shot = snapshot_info.spot_balance_snapshot_records.where(origin_symbol: h.origin_symbol, event_date: snapshot_info.event_date, source: h.source).first_or_initialize
        snap_shot.update(from_symbol: h.from_symbol, to_symbol: h.to_symbol, qty: h.qty, price: h.price, amount: h.amount)
      end
    end
  end
end
