class SpotBalanceSnapshotRecord < ApplicationRecord
  belongs_to :spot_balance_snapshot_info

  scope :available, -> { where("qty > 0") }

  delegate :user_id, to: :spot_balance_snapshot_info

  def roi
    revenue / amount
  end

  def self.summary
    data = SpotBalanceSnapshotRecord.available

    {
      total_cost: data.sum(&:amount),
      total_revenue: data.sum(&:revenue)
    }
  end

  def self.last_summary(data: nil)
    records = SpotBalanceSnapshotRecord.available.summary

    {
      total_cost: display_number(data[:total_cost] - records[:total_cost]),
      total_revenue: display_number(data[:total_revenue] - records[:total_revenue])
    }
  end

  private
  def self.display_number(num)
    num.to_f.round(2)
  end
end
