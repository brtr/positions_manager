class CombineTransaction < ApplicationRecord
  def self.total_summary
    records = CombineTransaction.where('qty != 0')
    total_cost = records.sum(&:amount)
    total_revenue = records.sum(&:revenue)
    total_roi = total_cost.zero? ? 0 : (total_revenue / total_cost) * 100
    profit_records = records.select{|r| r.revenue > 0}
    loss_records = records.select{|r| r.revenue < 0}
    profit_amount = profit_records.sum(&:revenue)
    loss_amount = loss_records.sum(&:revenue)
    date = Date.yesterday
    infos = CombineTxSnapshotInfo.includes(:combine_tx_snapshot_records).where("event_date <= ?", date)
    {
      profit_count: profit_records.count,
      profit_amount: profit_amount,
      loss_count: loss_records.count,
      loss_amount: loss_amount,
      total_cost: total_cost,
      total_revenue: total_revenue,
      total_roi: total_roi,
      max_profit: infos.max_profit,
      max_profit_date: $redis.get("user_#{date.to_s}_combine_spots_max_profit_date"),
      max_loss: infos.max_loss,
      max_loss_date: $redis.get("user_#{date.to_s}_combine_spots_max_loss_date"),
      max_revenue: infos.max_revenue,
      max_revenue_date: $redis.get("user_#{date.to_s}_combine_spots_max_revenue_date"),
      min_revenue: infos.min_revenue,
      min_revenue_date: $redis.get("user_#{date.to_s}_combine_spots_min_revenue_date"),
      max_roi: infos.max_roi,
      max_roi_date: $redis.get("user_#{date.to_s}_combine_spots_max_roi_date"),
      min_roi: infos.min_roi,
      min_roi_date: $redis.get("user_#{date.to_s}_combine_spots_min_roi_date"),
      max_profit_roi: infos.max_profit_roi,
      max_profit_roi_date: $redis.get("user_#{date.to_s}_combine_spots_max_profit_roi_date"),
      max_loss_roi: infos.max_loss_roi,
      max_loss_roi_date: $redis.get("user_#{date.to_s}_combine_spots_max_loss_roi_date")
    }
  end

  def revenue_ratio(summary)
    case
    when revenue > 0
      revenue / summary[:profit_amount]
    when revenue < 0
      revenue / summary[:loss_amount]
    else
      0
    end
  end

  def cost_ratio(total_cost)
    amount / total_cost
  end
end
