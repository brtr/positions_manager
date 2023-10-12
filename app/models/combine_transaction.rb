class CombineTransaction < ApplicationRecord
  def self.total_summary
    records = CombineTransaction.where('qty != 0')
    total_cost = records.sum(&:amount)
    total_revenue = records.sum(&:revenue)
    total_roi = total_cost.zero? ? 0 : (total_revenue / total_cost) * 100
    profit_records = records.select{|r| r.revenue > 0}
    loss_records = records.select{|r| r.revenue < 0}
    profit_amount = profit_records.sum(&:revenue)
    profit_roi = total_cost.zero? ? 0 : (profit_amount / total_cost) * 100
    loss_amount = loss_records.sum(&:revenue)
    loss_roi = total_cost.zero? ? 0 : (loss_amount / total_cost) * 100
    {
      profit_count: profit_records.count,
      profit_amount: profit_amount,
      loss_count: loss_records.count,
      loss_amount: loss_amount,
      total_cost: total_cost,
      total_revenue: total_revenue,
      total_roi: total_roi,
      profit_roi: profit_roi,
      loss_roi: loss_roi
    }
  end

  def revenue_ratio(total_revenue)
    ratio = (revenue / total_revenue).abs
    revenue > 0 ? ratio : ratio * -1
  end

  def cost_ratio(total_cost)
    amount / total_cost
  end
end
