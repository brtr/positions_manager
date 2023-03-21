class UserSyncedPosition < ApplicationRecord
  belongs_to :user

  scope :available, -> { where("qty > 0") }

  enum source: [:binance, :okx, :huobi]

  def amount
    qty * price
  end

  def revenue
    if trade_type == "sell"
      current_price.to_f * qty - amount
    else
      amount - current_price.to_f * qty
    end
  end

  def roi
    revenue / amount
  end

  def cost_ratio(total_cost)
    amount / total_cost
  end

  def revenue_ratio(total_revenue)
    ratio = (revenue / total_revenue).abs
    revenue > 0 ? ratio : ratio * -1
  end

  def margin_revenue
    (revenue - last_revenue).round(4) rescue 0
  end

  def self.total_summary(user_id=nil)
    records = UserSyncedPosition.where(user_id: user_id)
    profit_records = records.select{|r| r.revenue > 0}
    loss_records = records.select{|r| r.revenue < 0}
    date = Date.yesterday
    infos = SnapshotInfo.synced.includes(:snapshot_positions).where("event_date <= ?", date)
    {
      profit_count: profit_records.count,
      profit_amount: profit_records.sum(&:revenue),
      loss_count: loss_records.count,
      loss_amount: loss_records.sum(&:revenue),
      total_cost: records.sum(&:amount),
      total_revenue: records.sum(&:revenue),
      max_profit: infos.max_profit(user_id: user_id, is_synced: true, date: date),
      max_profit_date: $redis.get("user_#{user_id}_#{date.to_s}_synced_positions_max_profit_date"),
      max_loss: infos.max_loss(user_id: user_id, is_synced: true, date: date),
      max_loss_date: $redis.get("user_#{user_id}_#{date.to_s}_synced_positions_max_loss_date"),
      max_revenue: infos.max_revenue(user_id: user_id, is_synced: true, date: date),
      max_revenue_date: $redis.get("user_#{user_id}_#{date.to_s}_synced_positions_max_revenue_date"),
      min_revenue: infos.min_revenue(user_id: user_id, is_synced: true, date: date),
      min_revenue_date: $redis.get("user_#{user_id}_#{date.to_s}_synced_positions_min_revenue_date"),
      max_roi: infos.max_roi(user_id: user_id, is_synced: true, date: date),
      max_roi_date: $redis.get("user_#{user_id}_#{date.to_s}_synced_positions_max_roi_date"),
      min_roi: infos.min_roi(user_id: user_id, is_synced: true, date: date),
      min_roi_date: $redis.get("user_#{user_id}_#{date.to_s}_synced_positions_min_roi_date")
    }
  end
end
