class SyncedTransaction < ApplicationRecord
  scope :available, -> { where.not(revenue: 0) }

  def self.total_summary
    records = SyncedTransaction.available
    profit_records = records.select{|r| r.revenue > 0}
    loss_records = records.select{|r| r.revenue < 0}
    {
      profit_count: profit_records.count,
      profit_amount: profit_records.sum(&:revenue),
      loss_count: loss_records.count,
      loss_amount: loss_records.sum(&:revenue),
      total_cost: records.sum(&:total_cost),
      total_revenue: records.sum(&:revenue),
      total_fee: records.sum(&:fee)
    }
  end

  def roi
    revenue / amount.abs
  end

  def cost_price
    total_cost / qty.abs
  end

  def total_cost
    position_side == 'long' ? amount.abs - revenue : amount.abs + revenue
  end
end
