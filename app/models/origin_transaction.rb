class OriginTransaction < ApplicationRecord
  def self.total_summary(user_id=nil)
    records = OriginTransaction.all
    redis_key = "origin_transactions_total_summary_#{user_id}"
    result = $redis.get(redis_key)
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
      $redis.set(redis_key, result, ex: 5.hours)
    end
    JSON.parse result
  end

  def revenue_ratio(total_revenue)
    ratio = (revenue / total_revenue).abs
    revenue > 0 ? ratio : ratio * -1
  end

  def cost_ratio(total_cost)
    amount / total_cost
  end
end
