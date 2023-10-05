class OriginTransaction < ApplicationRecord
  SKIP_SYMBOLS = %w(USDC BTC ETH).freeze

  def self.available
    OriginTransaction.where('(from_symbol IN (?) AND amount >= 50) OR from_symbol NOT IN (?)', SKIP_SYMBOLS, SKIP_SYMBOLS)
  end

  def self.year_to_date
    OriginTransaction.where('event_time >= ?', DateTime.parse('2023-01-01'))
  end

  def self.total_summary(user_id=nil)
    records = OriginTransaction.available
    profit_records = records.select{|r| r.revenue > 0}
    loss_records = records.select{|r| r.revenue < 0}
    total_cost = calculate_field(records, :amount)
    total_estimated_revenue = records.where(trade_type: 'buy').sum(&:revenue)
    total_roi = total_cost.zero? ? 0 : total_estimated_revenue / total_cost
    date = Date.yesterday
    infos = TransactionsSnapshotInfo.includes(:snapshot_records).where("event_date <= ?", date)

    {
      profit_count: profit_records.count,
      profit_amount: calculate_field(profit_records),
      loss_count: loss_records.count,
      loss_amount: calculate_field(loss_records),
      total_cost: total_cost,
      total_revenue: records.where(trade_type: 'sell').sum(&:revenue),
      total_estimated_revenue: total_estimated_revenue,
      total_roi: total_roi,
      max_profit: infos.max_profit(user_id: user_id),
      max_profit_date: $redis.get("user_#{user_id}_#{date.to_s}_spots_max_profit_date"),
      max_loss: infos.max_loss(user_id: user_id),
      max_loss_date: $redis.get("user_#{user_id}_#{date.to_s}_spots_max_loss_date"),
    }
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
