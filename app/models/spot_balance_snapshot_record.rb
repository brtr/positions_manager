class SpotBalanceSnapshotRecord < ApplicationRecord
  belongs_to :spot_balance_snapshot_info

  scope :available, -> { where("qty > 0") }

  delegate :user_id, to: :spot_balance_snapshot_info

  def self.summary
    data = SpotBalanceSnapshotRecord.available

    {
      total_amount: data.sum(&:amount),
      total_revenue: data.sum(&:revenue)
    }
  end

  def self.last_summary(data: nil)
    records = SpotBalanceSnapshotRecord.available.summary

    {
      total_amount: display_number(data[:total_amount] - records[:total_amount]),
      total_revenue: display_number(data[:total_revenue] - records[:total_revenue])
    }
  end

  private
  def self.display_number(num)
    num >= 1 || num <= -1 ? num.round(4) : ''
  end
end
