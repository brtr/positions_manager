class TransactionsSnapshotInfo < ApplicationRecord
  has_many :snapshot_records, class_name: 'TransactionsSnapshotRecord', foreign_key: :transactions_snapshot_info_id

  def total_profit
    snapshot_records.available.year_to_date.profit.sum(&:revenue)
  end

  def total_loss
    snapshot_records.available.year_to_date.loss.sum(&:revenue)
  end

  def total_revenue
    snapshot_records.available.year_to_date.where(trade_type: 'buy').sum(&:revenue)
  end

  def self.max_profit(user_id: nil, date: Date.yesterday)
    redis_key = "user_#{user_id}_#{date.to_s}_spots_max_profit"
    total_profit = $redis.get(redis_key).to_f
    if total_profit == 0
      infos = TransactionsSnapshotInfo.joins(:snapshot_records)
      max_profit = infos.max {|a, b| a.total_profit <=> b.total_profit}
      if max_profit
        total_profit = max_profit.total_profit
        $redis.set(redis_key, total_profit, ex: 10.hours)
        $redis.set("#{redis_key}_date", max_profit.event_date.strftime("%Y-%m-%d"), ex: 10.hours)
      end
    end
    total_profit
  end

  def self.max_loss(user_id: nil, date: Date.yesterday)
    redis_key = "user_#{user_id}_#{date.to_s}_spots_max_loss"
    total_loss = $redis.get(redis_key).to_f
    if total_loss == 0
      infos = TransactionsSnapshotInfo.joins(:snapshot_records)
      max_loss = infos.min {|a, b| a.total_loss <=> b.total_loss}
      if max_loss
        total_loss = max_loss.total_loss
        $redis.set(redis_key, total_loss, ex: 10.hours)
        $redis.set("#{redis_key}_date", max_loss.event_date.strftime("%Y-%m-%d"), ex: 10.hours)
      end
    end
    total_loss
  end
end
