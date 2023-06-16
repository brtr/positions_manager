class UpdateFundingFeeSnapshotPositionIdService
  class << self
    def execute
      FundingFeeHistory.where(snapshot_position_id: nil).each do |h|
        snapshot = SnapshotPosition.joins(:snapshot_info).where(snapshot_info: { user_id: h.user_id }, event_date: h.event_date, origin_symbol: h.origin_symbol, source: h.source).take
        next unless snapshot.present?
        h.update(snapshot_position_id: snapshot.id)
      end
    end
  end
end
