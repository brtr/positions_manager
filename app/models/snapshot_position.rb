class SnapshotPosition < ApplicationRecord
  belongs_to :snapshot_info

  scope :available, -> { where("qty > 0") }
  scope :profit, -> { where("revenue > 0") }
  scope :loss, -> { where("revenue < 0") }

  def self.total_summary(user_id=nil)
    records = SnapshotPosition.available
    profit_records = records.profit
    loss_records = records.loss

    {
      total_cost: records.sum(&:amount).to_f,
      total_revenue: records.sum(&:revenue).to_f,
      profit_count: profit_records.count,
      profit_amount: profit_records.sum(&:revenue),
      loss_count: loss_records.count,
      loss_amount: loss_records.sum(&:revenue)
    }
  end

  def self.last_summary(user_id: nil, data: nil)
    latest_summary = data.present? ? data.total_summary(user_id) : UserPosition.total_summary(user_id)
    records = SnapshotPosition.available.total_summary(user_id)

    {
      total_cost: display_number(latest_summary[:total_cost] - records[:total_cost]),
      total_revenue: display_number(latest_summary[:total_revenue] - records[:total_revenue]),
      profit_count: display_number(latest_summary[:profit_count] - records[:profit_count]),
      profit_amount: display_number(latest_summary[:profit_amount] - records[:profit_amount]),
      loss_count: display_number(latest_summary[:loss_count] - records[:loss_count]),
      loss_amount: display_number(latest_summary[:loss_amount] - records[:loss_amount])
    }
  end

  def roi
    revenue / amount
  end

  private
  def self.display_number(num)
    num >= 1 || num <= -1 ? num.round(3) : ''
  end
end
