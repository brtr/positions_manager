class GetPositionsSummarySnapshotsService
  class << self
    def execute(date = Date.today)
      info = SnapshotInfo.includes(:snapshot_positions).find_by(user_id: nil, event_date: date)
      total_summary = info.snapshot_positions.total_summary
      last_summary = SnapshotPosition.joins(:snapshot_info).where(snapshot_info: {user_id: nil, event_date: info.event_date - 1.day}).last_summary(data: total_summary)
      total_revenue = total_summary[:total_revenue]
      roi = total_revenue / total_summary[:total_cost]
      snapshot = PositionsSummarySnapshot.where(event_date: date).first_or_initialize
      snapshot.update(
        total_cost: total_summary[:total_cost],
        total_revenue: total_revenue,
        total_loss: total_summary[:loss_amount],
        total_profit: total_revenue,
        roi: roi,
        revenue_change: last_summary[:total_revenue]
      )
    end
  end
end