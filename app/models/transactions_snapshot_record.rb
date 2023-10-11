class TransactionsSnapshotRecord < ApplicationRecord
  SKIP_SYMBOLS = %w(USDC BTC ETH).freeze

  belongs_to :snapshot_info, class_name: 'TransactionsSnapshotInfo', foreign_key: :transactions_snapshot_info_id

  scope :profit, -> { where("revenue > 0") }
  scope :loss, -> { where("revenue < 0") }

  def self.available
    TransactionsSnapshotRecord.where('(from_symbol IN (?) AND amount >= 50) OR from_symbol NOT IN (?)', SKIP_SYMBOLS, SKIP_SYMBOLS)
  end

  def self.year_to_date
    TransactionsSnapshotRecord.where('event_time >= ?', DateTime.parse('2023-01-01'))
  end

  def self.total_summary
    records = TransactionsSnapshotRecord.available.year_to_date.where(trade_type: 'buy')
    profit_records = records.select{|r| r.revenue > 0}
    loss_records = records.select{|r| r.revenue < 0}
    result = {
      profit_count: profit_records.count,
      profit_amount: profit_records.sum(&:revenue),
      loss_count: loss_records.count,
      loss_amount: loss_records.sum(&:revenue),
      total_cost: records.sum(&:amount),
      total_revenue: records.sum(&:revenue)
    }
  end

  def revenue_ratio(total_cost)
    (revenue / total_cost).abs
  end

  def cost_ratio(total_cost)
    amount / total_cost
  end
end
