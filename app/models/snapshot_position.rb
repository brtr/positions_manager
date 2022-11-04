class SnapshotPosition < ApplicationRecord
  belongs_to :snapshot_info

  scope :available, -> { where("qty > 0") }
  scope :profit, -> { where("revenue > 0") }
  scope :loss, -> { where("revenue < 0") }

  def self.total_summary(user_id=nil)
    latest_summary = UserPosition.total_summary(user_id)

    records = SnapshotPosition.available
    total_cost = latest_summary[:total_cost] - records.sum(&:amount).to_f
    total_revenue = latest_summary[:total_revenue] - records.sum(&:revenue).to_f
    profit_records = records.profit
    loss_records = records.loss

    {
      total_cost: total_cost,
      total_revenue: total_revenue,
      profit_count: latest_summary[:profit_count] - profit_records.count,
      profit_amount: latest_summary[:profit_amount] - profit_records.sum(&:revenue),
      loss_count: latest_summary[:loss_count] - loss_records.count,
      loss_amount: latest_summary[:loss_amount] - loss_records.sum(&:revenue)
    }
  end

  def roi
    revenue / amount
  end
end
