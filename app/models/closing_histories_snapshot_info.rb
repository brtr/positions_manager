class ClosingHistoriesSnapshotInfo < ApplicationRecord
  has_many :closing_histories_snapshot_records

  def total_profit
    closing_histories_snapshot_records.profit.sum(&:revenue)
  end

  def total_loss
    closing_histories_snapshot_records.loss.sum(&:revenue)
  end

  def total_revenue
    closing_histories_snapshot_records.sum(&:revenue)
  end

  def margin_summary
    last_info = ClosingHistoriesSnapshotInfo.find_by(event_date: event_date - 1.day)
    {
      total_cost: display_number(total_cost - last_info&.total_cost.to_f),
      total_revenue: display_number(total_revenue - last_info&.total_revenue.to_f),
      profit_count: display_number(profit_count - last_info&.profit_count.to_f),
      profit_amount: display_number(profit_amount - last_info&.profit_amount.to_f),
      loss_count: display_number(loss_count - last_info&.loss_count.to_f),
      loss_amount: display_number(loss_amount - last_info&.loss_amount.to_f),
      roi: display_number(total_roi - last_info&.total_roi.to_f)
    }
  end

  def self.max_profit(date: Date.yesterday)
    redis_key = "#{date.to_s}_closing_histories_max_profit"
    total_profit = $redis.get(redis_key).to_f
    if total_profit == 0
      max_profit = ClosingHistoriesSnapshotInfo.all.max {|a, b| a.total_profit <=> b.total_profit}
      if max_profit
        total_profit = max_profit.total_profit
        $redis.set(redis_key, total_profit, ex: 2.hours)
        $redis.set("#{redis_key}_date", max_profit.event_date.strftime("%Y-%m-%d"), ex: 2.hours)
      end
    end
    total_profit
  end

  def self.max_loss(date: Date.yesterday)
    redis_key = "#{date.to_s}_closing_histories_max_loss"
    total_loss = $redis.get(redis_key).to_f
    if total_loss == 0
      max_loss = ClosingHistoriesSnapshotInfo.all.min {|a, b| a.total_loss <=> b.total_loss}
      if max_loss
        total_loss = max_loss.total_loss
        $redis.set(redis_key, total_loss, ex: 2.hours)
        $redis.set("#{redis_key}_date", max_loss.event_date.strftime("%Y-%m-%d"), ex: 2.hours)
      end
    end
    total_loss
  end

  def self.max_revenue(date: Date.yesterday)
    redis_key = "#{date.to_s}_closing_histories_max_revenue"
    total_revenue = $redis.get(redis_key).to_f
    if total_revenue == 0
      max_revenue = ClosingHistoriesSnapshotInfo.all.max {|a, b| a.total_revenue <=> b.total_revenue}
      if max_revenue
        total_revenue = max_revenue.total_revenue
        $redis.set(redis_key, total_revenue, ex: 2.hours)
        $redis.set("#{redis_key}_date", max_revenue.event_date.strftime("%Y-%m-%d"), ex: 2.hours)
      end
    end
    total_revenue
  end

  def self.min_revenue(date: Date.yesterday)
    redis_key = "#{date.to_s}_closing_histories_min_revenue"
    total_revenue = $redis.get(redis_key).to_f
    if total_revenue == 0
      min_revenue = ClosingHistoriesSnapshotInfo.all.min {|a, b| a.total_revenue <=> b.total_revenue}
      if min_revenue
        total_revenue = min_revenue.total_revenue
        $redis.set(redis_key, total_revenue, ex: 2.hours)
        $redis.set("#{redis_key}_date", min_revenue.event_date.strftime("%Y-%m-%d"), ex: 2.hours)
      end
    end
    total_revenue
  end

  def self.max_roi(date: Date.yesterday)
    redis_key = "#{date.to_s}_closing_histories_max_roi"
    total_roi = $redis.get(redis_key).to_f
    if total_roi == 0
      max_roi = ClosingHistoriesSnapshotInfo.all.max {|a, b| a.total_roi <=> b.total_roi}
      if max_roi
        total_roi = max_roi.total_roi
        $redis.set(redis_key, total_roi, ex: 2.hours)
        $redis.set("#{redis_key}_date", max_roi.event_date.strftime("%Y-%m-%d"), ex: 2.hours)
      end
    end
    total_roi.to_f
  end

  def self.min_roi(date: Date.yesterday)
    redis_key = "#{date.to_s}_closing_histories_min_roi"
    total_roi = $redis.get(redis_key).to_f
    if total_roi == 0
      min_roi = ClosingHistoriesSnapshotInfo.all.min {|a, b| a.total_roi <=> b.total_roi}
      if min_roi
        total_roi = min_roi.total_roi
        $redis.set(redis_key, total_roi, ex: 2.hours)
        $redis.set("#{redis_key}_date", min_roi.event_date.strftime("%Y-%m-%d"), ex: 2.hours)
      end
    end
    total_roi.to_f
  end

  private
  def display_number(num)
    num.to_f.round(2)
  end
end
