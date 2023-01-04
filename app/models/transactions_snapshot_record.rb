class TransactionsSnapshotRecord < ApplicationRecord
  belongs_to :snapshot_info, class_name: 'TransactionsSnapshotInfo', foreign_key: :transactions_snapshot_info_id

  def self.total_summary
    records = TransactionsSnapshotRecord.where(trade_type: 'buy')
    result = $redis.get("origin_transactions_snapshots_total_summary")
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
      $redis.set("origin_transactions_snapshots_total_summary", result, ex: 5.hours)
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