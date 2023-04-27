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
        profit_amount: calculate_field(profit_records),
        loss_count: loss_records.count,
        loss_amount: calculate_field(loss_records),
        total_cost: calculate_field(records, :amount),
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

  private
  def self.calculate_field(records, field_name = :revenue)
    buys, sells = records.partition { |record| record.trade_type == "buy" }
    buys.sum { |record| record.send(field_name) } - sells.sum { |record| record.send(field_name) }
  end
end
