class CombineTxSnapshotInfo < ApplicationRecord
  has_many :combine_tx_snapshot_records, dependent: :destroy

  def total_profit
    combine_tx_snapshot_records.profit.sum(&:revenue)
  end

  def total_loss
    combine_tx_snapshot_records.loss.sum(&:revenue)
  end

  def total_revenue
    combine_tx_snapshot_records.sum(&:revenue)
  end

  def total_cost
    combine_tx_snapshot_records.sum(&:amount)
  end

  def total_roi
    total_cost.zero? ? 0 : ((total_revenue / total_cost) * 100).round(4)
  end

  def total_profit_roi
    total_cost.zero? ? 0 : ((total_profit / total_cost) * 100).round(4)
  end

  def total_loss_roi
    total_cost.zero? ? 0 : ((total_loss / total_cost) * 100).round(4)
  end

  def self.max_profit(date: Date.yesterday)
    redis_key = "user_#{date.to_s}_combine_spots_max_profit"
    total_profit = $redis.get(redis_key).to_f
    if total_profit == 0
      infos = CombineTxSnapshotInfo.joins(:combine_tx_snapshot_records)
      max_profit = infos.max {|a, b| a.total_profit <=> b.total_profit}
      if max_profit
        total_profit = max_profit.total_profit
        $redis.set(redis_key, total_profit, ex: 10.hours)
        $redis.set("#{redis_key}_date", max_profit.event_date.strftime("%Y-%m-%d"), ex: 10.hours)
      end
    end
    total_profit
  end

  def self.max_loss(date: Date.yesterday)
    redis_key = "user_#{date.to_s}_combine_spots_max_loss"
    total_loss = $redis.get(redis_key).to_f
    if total_loss == 0
      infos = CombineTxSnapshotInfo.joins(:combine_tx_snapshot_records)
      max_loss = infos.min {|a, b| a.total_loss <=> b.total_loss}
      if max_loss
        total_loss = max_loss.total_loss
        $redis.set(redis_key, total_loss, ex: 10.hours)
        $redis.set("#{redis_key}_date", max_loss.event_date.strftime("%Y-%m-%d"), ex: 10.hours)
      end
    end
    total_loss
  end

  def self.max_revenue(date: Date.yesterday)
    redis_key = "user_#{date.to_s}_combine_spots_max_revenue"
    total_revenue = $redis.get(redis_key).to_f
    if total_revenue == 0
      infos = CombineTxSnapshotInfo.joins(:combine_tx_snapshot_records)
      max_revenue = infos.max {|a, b| a.total_revenue <=> b.total_revenue}
      if max_revenue
        total_revenue = max_revenue.total_revenue
        $redis.set(redis_key, total_revenue, ex: 10.hours)
        $redis.set("#{redis_key}_date", max_revenue.event_date.strftime("%Y-%m-%d"), ex: 10.hours)
      end
    end
    total_revenue
  end

  def self.min_revenue(date: Date.yesterday)
    redis_key = "user_#{date.to_s}_combine_spots_min_revenue"
    total_revenue = $redis.get(redis_key).to_f
    if total_revenue == 0
      infos = CombineTxSnapshotInfo.joins(:combine_tx_snapshot_records)
      min_revenue = infos.min {|a, b| a.total_revenue <=> b.total_revenue}
      if min_revenue
        total_revenue = min_revenue.total_revenue
        $redis.set(redis_key, total_revenue, ex: 10.hours)
        $redis.set("#{redis_key}_date", min_revenue.event_date.strftime("%Y-%m-%d"), ex: 10.hours)
      end
    end
    total_revenue
  end

  def self.max_roi(date: Date.yesterday)
    redis_key = "user_#{date.to_s}_combine_spots_max_roi"
    total_roi = $redis.get(redis_key).to_f
    if total_roi == 0
      infos = CombineTxSnapshotInfo.joins(:combine_tx_snapshot_records)
      max_roi = infos.max {|a, b| a.total_roi <=> b.total_roi}
      if max_roi
        total_roi = max_roi.total_roi
        $redis.set(redis_key, total_roi, ex: 10.hours)
        $redis.set("#{redis_key}_date", max_roi.event_date.strftime("%Y-%m-%d"), ex: 10.hours)
      end
    end
    total_roi.to_f
  end

  def self.min_roi(date: Date.yesterday)
    redis_key = "user_#{date.to_s}_combine_spots_min_roi"
    total_roi = $redis.get(redis_key).to_f
    if total_roi == 0
      infos = CombineTxSnapshotInfo.joins(:combine_tx_snapshot_records)
      min_roi = infos.min {|a, b| a.total_roi <=> b.total_roi}
      if min_roi
        total_roi = min_roi.total_roi
        $redis.set(redis_key, total_roi, ex: 10.hours)
        $redis.set("#{redis_key}_date", min_roi.event_date.strftime("%Y-%m-%d"), ex: 10.hours)
      end
    end
    total_roi.to_f
  end

  def self.max_profit_roi(date: Date.yesterday)
    redis_key = "user_#{date.to_s}_combine_spots_max_profit_roi"
    total_roi = $redis.get(redis_key).to_f
    if total_roi == 0
      infos = CombineTxSnapshotInfo.joins(:combine_tx_snapshot_records)
      max_roi = infos.max {|a, b| a.total_profit_roi <=> b.total_profit_roi}
      if max_roi
        total_roi = max_roi.total_profit_roi
        $redis.set(redis_key, total_roi, ex: 10.hours)
        $redis.set("#{redis_key}_date", max_roi.event_date.strftime("%Y-%m-%d"), ex: 10.hours)
      end
    end
    total_roi.to_f
  end

  def self.max_loss_roi(date: Date.yesterday)
    redis_key = "user_#{date.to_s}_combine_spots_max_loss_roi"
    total_roi = $redis.get(redis_key).to_f
    if total_roi == 0
      infos = CombineTxSnapshotInfo.joins(:combine_tx_snapshot_records)
      max_roi = infos.min {|a, b| a.total_loss_roi <=> b.total_loss_roi}
      if max_roi
        total_roi = max_roi.total_loss_roi
        $redis.set(redis_key, total_roi, ex: 10.hours)
        $redis.set("#{redis_key}_date", max_roi.event_date.strftime("%Y-%m-%d"), ex: 10.hours)
      end
    end
    total_roi.to_f
  end
end
