class CombineTransaction < ApplicationRecord
  def self.total_summary
    records = CombineTransaction.where('qty != 0')
    result = $redis.get("combine_transactions_total_summary")
    if result.nil?
      profit_records = records.select{|r| r.revenue > 0}
      loss_records = records.select{|r| r.revenue < 0}
      result = {
        profit_count: profit_records.count,
        profit_amount: profit_records.sum(&:revenue),
        loss_count: loss_records.count,
        loss_amount: loss_records.sum(&:revenue),
        total_cost: records.sum(&:amount),
        total_revenue: records.sum(&:revenue)
      }.to_json
      $redis.set("combine_transactions_total_summary", result, ex: 5.hours)
    end
    JSON.parse result
  end

  def revenue_ratio(total_cost)
    (revenue / total_cost).abs
  end

  def cost_ratio(total_cost)
    amount / total_cost
  end
end
