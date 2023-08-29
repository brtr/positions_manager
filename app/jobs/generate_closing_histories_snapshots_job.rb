class GenerateClosingHistoriesSnapshotsJob < ApplicationJob
  queue_as :daily_job

  def perform(date: Date.today)
    snapshot_info = ClosingHistoriesSnapshotInfo.where(event_date: date).first_or_create
    data = AddingPositionsHistory.closing_data.available
    generate_snapshot(snapshot_info, data)
    generate_snapshot_summary(snapshot_info, date, data)
  end

  def generate_snapshot(snapshot_info, data)
    ClosingHistoriesSnapshotRecord.transaction do
      data.each do |h|
        snap_shot = snapshot_info.closing_histories_snapshot_records.where(origin_symbol: h.origin_symbol, trade_type: h.trade_type, event_date: h.event_date, source: h.source).first_or_create
        snap_shot.update(from_symbol: h.from_symbol, fee_symbol: h.fee_symbol, qty: h.qty, price: h.price, roi: h.roi, trading_roi: h.trading_roi,
                        amount: h.amount, current_price: h.current_price, revenue: h.get_revenue, amount_ratio: h.amount_ratio, unit_cost: h.unit_cost)
      end
    end
  end

  def generate_snapshot_summary(snapshot_info, date, data)
    total_summary = date == Date.today ? data.total_summary : snapshot_info.closing_histories_snapshot_records.total_summary(date: date)
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
      min_roi: total_summary[:min_roi],
      min_roi_date: total_summary[:min_roi_date]
    )
  end
end
