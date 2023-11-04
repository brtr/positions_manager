class GetTransactionsSnapshotInfoSummaryJob < ApplicationJob
  queue_as :default

  def perform(snapshot_info, date)
    total_summary = date == Date.today ? OriginTransaction.total_summary : snapshot_info.snapshot_records.total_summary(date: snapshot_info.event_date)
    total_revenue = total_summary[:total_revenue].to_f
    total_cost = total_summary[:total_cost].to_f
    total_roi = total_cost == 0 ? 0 : ((total_revenue / total_cost) * 100).round(4)

    snapshot_info.update(
      profit_count: total_summary[:profit_count],
      profit_amount: total_summary[:profit_amount],
      loss_count: total_summary[:loss_count],
      loss_amount: total_summary[:loss_amount],
      total_cost: total_cost,
      total_revenue: total_revenue,
      total_roi: total_roi,
      max_profit: total_summary[:max_profit],
      max_profit_date: total_summary[:max_profit_date],
      max_loss: total_summary[:max_loss],
      max_loss_date: total_summary[:max_loss_date],
      max_revenue: total_summary[:max_revenue],
      max_revenue_date: total_summary[:max_revenue_date],
      min_revenue: total_summary[:min_revenue],
      min_revenue_date: total_summary[:min_revenue_date],
      max_roi: total_summary[:max_roi],
      max_roi_date: total_summary[:max_roi_date],
      max_profit_roi: total_summary[:max_profit_roi],
      max_profit_roi_date: total_summary[:max_profit_roi_date],
      max_loss_roi: total_summary[:max_loss_roi],
      max_loss_roi_date: total_summary[:max_loss_roi_date],
      min_roi: total_summary[:min_roi],
      min_roi_date: total_summary[:min_roi_date]
    )
  end
end
