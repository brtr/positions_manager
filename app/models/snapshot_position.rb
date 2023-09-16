class SnapshotPosition < ApplicationRecord
  belongs_to :snapshot_info

  scope :available, -> { where("qty > 0") }
  scope :profit, -> { where("revenue > 0") }
  scope :loss, -> { where("revenue < 0") }

  before_create :set_init_value

  def self.total_summary(user_id: nil, is_synced: false, date: Date.yesterday)
    records = SnapshotPosition.available
    profit_records = records.profit
    loss_records = records.loss
    infos = SnapshotInfo.includes(:snapshot_positions).where("event_date <= ?", date)
    redis_key = is_synced ? "user_#{user_id}_#{date.to_s}_synced_positions" : "user_#{user_id}_#{date.to_s}_positions"

    {
      total_cost: records.sum(&:amount).to_f,
      total_revenue: records.sum(&:revenue).to_f,
      profit_count: profit_records.count,
      profit_amount: profit_records.sum(&:revenue),
      loss_count: loss_records.count,
      loss_amount: loss_records.sum(&:revenue),
      total_funding_fee: FundingFeeHistory.where('user_id is null and event_date <= ?', date - 1.day).sum(&:amount),
      max_profit: infos.max_profit(user_id: user_id, is_synced: is_synced, date: date),
      max_profit_date: $redis.get("#{redis_key}_max_profit_date"),
      max_loss: infos.max_loss(user_id: user_id, is_synced: is_synced, date: date),
      max_loss_date: $redis.get("#{redis_key}_max_loss_date"),
      max_revenue: infos.max_revenue(user_id: user_id, is_synced: is_synced, date: date),
      max_revenue_date: $redis.get("#{redis_key}_max_revenue_date"),
      min_revenue: infos.min_revenue(user_id: user_id, is_synced: is_synced, date: date),
      min_revenue_date: $redis.get("#{redis_key}_min_revenue_date"),
      max_roi: infos.max_roi(user_id: user_id, is_synced: is_synced, date: date),
      max_roi_date: $redis.get("#{redis_key}_max_roi_date"),
      min_roi: infos.min_roi(user_id: user_id, is_synced: is_synced, date: date),
      min_roi_date: $redis.get("#{redis_key}_min_roi_date")
    }
  end

  def self.last_summary(user_id: nil, data: nil)
    records = SnapshotPosition.available.total_summary(user_id: user_id)
    old_roi = records[:total_revenue].to_f / records[:total_cost].to_f
    new_roi = data[:total_revenue].to_f / data[:total_cost].to_f

    {
      total_cost: display_number(data[:total_cost] - records[:total_cost]),
      total_revenue: display_number(data[:total_revenue] - records[:total_revenue]),
      profit_count: display_number(data[:profit_count] - records[:profit_count]),
      profit_amount: display_number(data[:profit_amount] - records[:profit_amount]),
      loss_count: display_number(data[:loss_count] - records[:loss_count]),
      loss_amount: display_number(data[:loss_amount] - records[:loss_amount]),
      roi: display_number(new_roi * 100 - old_roi * 100),
      total_funding_fee: display_number(data[:total_funding_fee] - records[:total_funding_fee])
    }
  end

  def roi
    revenue / amount
  end

  def cost_ratio(total_cost)
    amount / total_cost rescue 0
  end

  def revenue_ratio(total_revenue)
    ratio = (revenue / total_revenue).abs
    revenue > 0 ? ratio : ratio * -1
  end

  def margin_revenue
    (revenue - last_revenue).round(4) rescue 0
  end

  private
  def self.display_number(num)
    num.to_f.round(2)
  end

  def set_init_value
    self.qty = 0 if qty.nil?
    self.amount = 0 if amount.nil?
  end
end
