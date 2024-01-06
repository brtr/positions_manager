class OriginTransaction < ApplicationRecord
  SKIP_SYMBOLS = %w(BTC ETH).freeze
  FILTER_SYMBOL = %w(USDC).freeze

  def self.available
    OriginTransaction.where.not(source: ['gate', 'bitget']).where('from_symbol NOT IN (?) and ((from_symbol IN (?) AND amount >= 50) OR from_symbol NOT IN (?))', FILTER_SYMBOL, SKIP_SYMBOLS, SKIP_SYMBOLS)
  end

  def self.year_to_date
    OriginTransaction.where('event_time >= ?', DateTime.parse('2023-01-01'))
  end

  def self.total_summary(user_id=nil)
    records = OriginTransaction.available.year_to_date
    profit_records = records.select{|r| r.revenue > 0}
    loss_records = records.select{|r| r.revenue < 0}
    total_cost = calculate_field(records, :amount)
    total_estimated_revenue = records.where(trade_type: 'buy').sum(&:revenue)
    total_roi = total_cost.zero? ? 0 : total_estimated_revenue / total_cost
    date = Date.yesterday
    infos = TransactionsSnapshotInfo.where("event_date <= ?", date)

    summary = {
      profit_count: profit_records.count,
      profit_amount: calculate_field(profit_records),
      loss_count: loss_records.count,
      loss_amount: calculate_field(loss_records),
      total_cost: total_cost,
      total_revenue: records.where(trade_type: 'sell').sum(&:revenue),
      total_estimated_revenue: total_estimated_revenue,
      total_roi: total_roi
    }

    summary.merge!({
      max_profit: infos.max_profit(user_id: user_id),
      max_profit_date: $redis.get("user_#{user_id}_#{date.to_s}_spots_max_profit_date"),
      max_loss: infos.max_loss(user_id: user_id),
      max_loss_date: $redis.get("user_#{user_id}_#{date.to_s}_spots_max_loss_date"),
      max_revenue: infos.max_revenue(user_id: user_id),
      max_revenue_date: $redis.get("user_#{user_id}_#{date.to_s}_spots_max_revenue_date"),
      min_revenue: infos.min_revenue(user_id: user_id),
      min_revenue_date: $redis.get("user_#{user_id}_#{date.to_s}_spots_min_revenue_date"),
      max_roi: infos.max_roi(user_id: user_id),
      max_roi_date: $redis.get("user_#{user_id}_#{date.to_s}_spots_max_roi_date"),
      min_roi: infos.min_roi(user_id: user_id),
      min_roi_date: $redis.get("user_#{user_id}_#{date.to_s}_spots_min_roi_date"),
      max_profit_roi: infos.max_profit_roi(user_id: user_id),
      max_profit_roi_date: $redis.get("user_#{user_id}_#{date.to_s}_spots_max_profit_roi_date"),
      max_loss_roi: infos.max_loss_roi(user_id: user_id),
      max_loss_roi_date: $redis.get("user_#{user_id}_#{date.to_s}_spots_max_loss_roi_date")
    }) if user_id.nil?

    summary
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
