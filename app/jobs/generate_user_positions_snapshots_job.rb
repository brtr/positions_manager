class GenerateUserPositionsSnapshotsJob < ApplicationJob
  queue_as :daily_job

  def perform(date: Date.today)
    user_ids = UserPosition.where("qty != ?", 0).pluck(:user_id).compact.uniq

    user_ids.each do |user_id|
      snapshot_info = SnapshotInfo.where(event_date: date, user_id: user_id).first_or_create
      generate_snapshot(snapshot_info)
      $redis.del("user_#{user_id}_positions_max_profit")
      $redis.del("user_#{user_id}_positions_max_profit_date")
      $redis.del("user_#{user_id}_positions_max_loss")
      $redis.del("user_#{user_id}_positions_max_loss_date")
    end

    snapshot_info = SnapshotInfo.where(event_date: date, user_id: nil).first_or_create
    generate_snapshot(snapshot_info)
    $redis.del('user__positions_max_profit')
    $redis.del('user__positions_max_profit_date')
    $redis.del('user__positions_max_loss')
    $redis.del('user__positions_max_loss_date')
  end

  def generate_snapshot(snapshot_info)
    SnapshotPosition.transaction do
      histories = UserPosition.where("qty != ?", 0)
      histories = snapshot_info.user_id ? histories.where(user_id: snapshot_info.user_id) : histories.where(user_id: nil)
      histories.each do |up|
        snap_shot = snapshot_info.snapshot_positions.where(origin_symbol: up.origin_symbol, trade_type: up.trade_type, event_date: snapshot_info.event_date, source: up.source).first_or_create
        snap_shot.update(from_symbol: up.from_symbol, fee_symbol: up.fee_symbol, qty: up.qty, price: up.price,
                        amount: up.amount, estimate_price: up.current_price, revenue: up.revenue)
      end
    end
  end
end
