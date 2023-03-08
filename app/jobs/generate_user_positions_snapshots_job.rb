class GenerateUserPositionsSnapshotsJob < ApplicationJob
  queue_as :daily_job

  def perform(date: Date.today)
    snapshot_info = SnapshotInfo.synced.where(event_date: date, user_id: nil).first_or_create
    generate_snapshot(snapshot_info)
    get_summary(snapshot_info, date, true)
    $redis.del("user__#{date.to_s}_positions_max_profit")
    $redis.del("user__#{date.to_s}_positions_max_profit_date")
    $redis.del("user__#{date.to_s}_positions_max_loss")
    $redis.del("user__#{date.to_s}_positions_max_loss_date")
    $redis.del("user__#{date.to_s}_positions_max_revenue")
    $redis.del("user__#{date.to_s}_positions_max_revenue_date")
    $redis.del("user__#{date.to_s}_positions_min_revenue")
    $redis.del("user__#{date.to_s}_positions_min_revenue_date")

    user_ids = UserPosition.where("qty != ?", 0).pluck(:user_id).compact.uniq
    user_ids.each do |user_id|
      snapshot_info = SnapshotInfo.uploaded.where(event_date: date, user_id: user_id).first_or_create
      generate_snapshot(snapshot_info)
      get_summary(snapshot_info, date, false)
      $redis.del("user_#{user_id}_#{date.to_s}_positions_max_profit")
      $redis.del("user_#{user_id}_#{date.to_s}_positions_max_profit_date")
      $redis.del("user_#{user_id}_#{date.to_s}_positions_max_loss")
      $redis.del("user_#{user_id}_#{date.to_s}_positions_max_loss_date")
      $redis.del("user_#{user_id}_#{date.to_s}_positions_max_revenue")
      $redis.del("user_#{user_id}_#{date.to_s}_positions_max_revenue_date")
      $redis.del("user_#{user_id}_#{date.to_s}_positions_min_revenue")
      $redis.del("user_#{user_id}_#{date.to_s}_positions_min_revenue_date")
    end

    user_ids = UserSyncedPosition.where("qty != ?", 0).pluck(:user_id).compact.uniq
    user_ids.each do |user_id|
      snapshot_info = SnapshotInfo.synced.where(event_date: date, user_id: user_id).first_or_create
      generate_synced_snapshot(snapshot_info)
      get_summary(snapshot_info, date, true)
      $redis.del("user_#{user_id}_#{date.to_s}_synced_positions_max_profit")
      $redis.del("user_#{user_id}_#{date.to_s}_synced_positions_max_profit_date")
      $redis.del("user_#{user_id}_#{date.to_s}_synced_positions_max_loss")
      $redis.del("user_#{user_id}_#{date.to_s}_synced_positions_max_loss_date")
      $redis.del("user_#{user_id}_#{date.to_s}_synced_positions_max_revenue")
      $redis.del("user_#{user_id}_#{date.to_s}_synced_positions_max_revenue_date")
      $redis.del("user_#{user_id}_#{date.to_s}_synced_positions_min_revenue")
      $redis.del("user_#{user_id}_#{date.to_s}_synced_positions_min_revenue_date")
    end
  end

  def generate_snapshot(snapshot_info)
    SnapshotPosition.transaction do
      histories = UserPosition.where("qty != ?", 0)
      histories = snapshot_info.user_id ? histories.where(user_id: snapshot_info.user_id) : histories.where(user_id: nil)
      histories.each do |up|
        snap_shot = snapshot_info.snapshot_positions.where(origin_symbol: up.origin_symbol, trade_type: up.trade_type, event_date: snapshot_info.event_date, source: up.source).first_or_create
        snap_shot.update(from_symbol: up.from_symbol, fee_symbol: up.fee_symbol, qty: up.qty, price: up.price, last_revenue: up.last_revenue,
                        amount: up.amount, estimate_price: up.current_price, revenue: up.revenue, margin_ratio: up.margin_ratio)
      end
    end
  end

  def generate_synced_snapshot(snapshot_info)
    SnapshotPosition.transaction do
      histories = UserSyncedPosition.where("qty != ? and user_id = ?", 0, snapshot_info.user_id)
      histories.each do |up|
        snap_shot = snapshot_info.snapshot_positions.where(origin_symbol: up.origin_symbol, trade_type: up.trade_type, event_date: snapshot_info.event_date, source: up.source).first_or_create
        snap_shot.update(from_symbol: up.from_symbol, fee_symbol: up.fee_symbol, qty: up.qty, price: up.price, last_revenue: up.last_revenue,
                        amount: up.amount, estimate_price: up.current_price, revenue: up.revenue, margin_ratio: up.margin_ratio)
      end
    end
  end

  def get_summary(snapshot_info, date, is_synced)
    user_id = snapshot_info.user_id
    total_summary = date == Date.today ? UserPosition.total_summary(user_id) : snapshot_info.snapshot_positions.total_summary(user_id: user_id, is_synced: is_synced, date: snapshot_info.event_date)
    ranking_snapshots = RankingSnapshot.where(event_date: snapshot_info.event_date)
    btc_data = ranking_snapshots.find_by(symbol: 'BTCBUSD')
    btc_change = btc_data.last_price - btc_data.open_price rescue nil
    snapshot_info.update(
      increase_count: ranking_snapshots.count{|s| s.price_change_rate > 0},
      decrease_count: ranking_snapshots.count{|s| s.price_change_rate < 0},
      btc_change: btc_change,
      btc_change_ratio: btc_data&.price_change_rate,
      profit_count: total_summary[:profit_count],
      profit_amount: total_summary[:profit_amount],
      loss_count: total_summary[:loss_count],
      loss_amount: total_summary[:loss_amount],
      total_cost:total_summary[:total_cost],
      total_revenue:total_summary[:total_revenue],
      total_roi: ((total_summary[:total_revenue].to_f / total_summary[:total_cost].to_f) * 100).round(3),
      max_profit: total_summary[:max_profit],
      max_profit_date: total_summary[:max_profit_date],
      max_loss: total_summary[:max_loss],
      max_loss_date: total_summary[:max_loss_date],
      max_revenue: total_summary[:max_revenue],
      max_revenue_date: total_summary[:max_revenue_date],
      min_revenue: total_summary[:min_revenue],
      min_revenue_date: total_summary[:min_revenue_date],
    )
  end
end
