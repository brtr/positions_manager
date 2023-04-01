class GetSnapshotInfoSummaryJob < ApplicationJob
  queue_as :default

  def perform(snapshot_info, date, is_synced)
    user_id = snapshot_info.user_id
    total_summary = date == Date.today ? UserPosition.total_summary(user_id) : snapshot_info.snapshot_positions.total_summary(user_id: user_id, is_synced: is_synced, date: snapshot_info.event_date)
    ranking_snapshots = RankingSnapshot.where(event_date: snapshot_info.event_date)
    btc_data = ranking_snapshots.find_by(symbol: 'BTCBUSD')
    btc_change = btc_data.last_price - btc_data.open_price rescue nil
    total_revenue = total_summary[:total_revenue].to_f
    total_cost = total_summary[:total_cost].to_f
    total_roi = total_cost == 0 ? 0 : ((total_revenue / total_cost) * 100).round(4)
    snapshot_info.update(
      increase_count: ranking_snapshots.count{|s| s.price_change_rate > 0},
      decrease_count: ranking_snapshots.count{|s| s.price_change_rate < 0},
      btc_change: btc_change,
      btc_change_ratio: btc_data&.price_change_rate,
      profit_count: total_summary[:profit_count],
      profit_amount: total_summary[:profit_amount],
      loss_count: total_summary[:loss_count],
      loss_amount: total_summary[:loss_amount],
      total_cost: total_cost,
      total_revenue: total_revenue,
      total_roi: total_roi,
      max_profit: total_summary[:max_profit],
      max_profit_date: total_summary[:max_profit_date],
      max_loss: total_summary[:max_loss],
      max_loss_date: total_summary[:max_loss_date],
      max_revenue: total_summary[:max_revenue],
      max_revenue_date: total_summary[:max_revenue_date],
      min_revenue: total_summary[:min_revenue],
      min_revenue_date: total_summary[:min_revenue_date],
      max_roi: total_summary[:max_roi],
      max_roi_date: total_summary[:max_roi_date],
      min_roi: total_summary[:min_roi],
      min_roi_date: total_summary[:min_roi_date]
    )
  end
end
