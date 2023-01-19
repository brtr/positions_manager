class SnapshotPosition < ApplicationRecord
  belongs_to :snapshot_info

  scope :available, -> { where("qty > 0") }
  scope :profit, -> { where("revenue > 0") }
  scope :loss, -> { where("revenue < 0") }

  def self.total_summary(user_id=nil, is_synced=false)
    records = SnapshotPosition.available
    profit_records = records.profit
    loss_records = records.loss
    infos = SnapshotInfo.includes(:snapshot_positions).where("event_date <= ?", Date.yesterday)
    redis_key = is_synced ? "user_#{user_id}_synced_positions" : "user_#{user_id}_positions"

    {
      total_cost: records.sum(&:amount).to_f,
      total_revenue: records.sum(&:revenue).to_f,
      profit_count: profit_records.count,
      profit_amount: profit_records.sum(&:revenue),
      loss_count: loss_records.count,
      loss_amount: loss_records.sum(&:revenue),
      max_profit: infos.max_profit(user_id, is_synced),
      max_profit_date: $redis.get("#{redis_key}_max_profit_date"),
      max_loss: infos.max_loss(user_id, is_synced),
      max_loss_date: $redis.get("#{redis_key}_max_loss_date")
    }
  end

  def self.last_summary(user_id: nil, data: nil)
    records = SnapshotPosition.available.total_summary(user_id)

    {
      total_cost: display_number(data[:total_cost] - records[:total_cost]),
      total_revenue: display_number(data[:total_revenue] - records[:total_revenue]),
      profit_count: display_number(data[:profit_count] - records[:profit_count]),
      profit_amount: display_number(data[:profit_amount] - records[:profit_amount]),
      loss_count: display_number(data[:loss_count] - records[:loss_count]),
      loss_amount: display_number(data[:loss_amount] - records[:loss_amount])
    }
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

  private
  def self.display_number(num)
    num >= 1 || num <= -1 ? num.round(3) : ''
  end
end
