class ClosingHistoriesSnapshotRecord < ApplicationRecord
  belongs_to :closing_histories_snapshot_info

  scope :profit, -> { where("revenue > 0") }
  scope :loss, -> { where("revenue < 0") }

  def self.total_summary(date: Date.yesterday)
    records = ClosingHistoriesSnapshotRecord.all
    profit_records = records.select{|r| r.revenue > 0}
    loss_records = records.select{|r| r.revenue < 0}
    total_amount = records.sum{|x| x.amount.abs}
    total_revenue = records.sum(&:revenue)
    infos = ClosingHistoriesSnapshotInfo.includes(:closing_histories_snapshot_records).where("event_date <= ?", date)
    redis_key = "#{date.to_s}_closing_histories_summary"

    {
      total_cost: total_amount + total_revenue,
      total_revenue: total_revenue,
      profit_count: profit_records.count,
      profit_amount: profit_records.sum(&:revenue),
      loss_count: loss_records.count,
      loss_amount: loss_records.sum(&:revenue),
      max_profit: infos.max_profit(date: date),
      max_profit_date: $redis.get("#{redis_key}_max_profit_date"),
      max_loss: infos.max_loss(date: date),
      max_loss_date: $redis.get("#{redis_key}_max_loss_date"),
      max_revenue: infos.max_revenue(date: date),
      max_revenue_date: $redis.get("#{redis_key}_max_revenue_date"),
      min_revenue: infos.min_revenue(date: date),
      min_revenue_date: $redis.get("#{redis_key}_min_revenue_date"),
      max_roi: infos.max_roi(date: date),
      max_roi_date: $redis.get("#{redis_key}_max_roi_date"),
      min_roi: infos.min_roi(date: date),
      min_roi_date: $redis.get("#{redis_key}_min_roi_date")
    }
  end

  def self.last_summary(data: nil)
    records = ClosingHistoriesSnapshotRecord.total_summary
    old_cost = records[:total_cost].to_f
    old_roi = old_cost.zero? ? 0 : records[:total_revenue].to_f / old_cost
    new_cost = data[:total_cost].to_f
    new_roi = new_cost.zero? ? 0 : data[:total_revenue].to_f / new_cost

    {
      total_cost: display_number(new_cost - old_cost),
      total_revenue: display_number(data[:total_revenue] - records[:total_revenue]),
      profit_count: display_number(data[:profit_count] - records[:profit_count]),
      profit_amount: display_number(data[:profit_amount] - records[:profit_amount]),
      loss_count: display_number(data[:loss_count] - records[:loss_count]),
      loss_amount: display_number(data[:loss_amount] - records[:loss_amount]),
      roi: old_roi.zero? ? 0 : display_number(new_roi * 100 - old_roi * 100)
    }
  end

  private
  def self.display_number(num)
    num.to_f.round(2)
  end
end
