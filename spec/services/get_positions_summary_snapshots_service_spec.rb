require "rails_helper"

RSpec.describe GetPositionsSummarySnapshotsService, type: :service do
  describe "GetPositionsSummarySnapshotsService" do
    it "gets positions summary snapshot" do
      snapshot_info = create(:snapshot_info, event_date: Date.today, user_id: nil)
      snapshot_position = create(:snapshot_position, snapshot_info_id: snapshot_info.id)

      last_snapshot_info = create(:snapshot_info, event_date: Date.yesterday, user_id: nil)
      last_snapshot_position = create(:snapshot_position, snapshot_info_id: last_snapshot_info.id)

      expect do
        GetPositionsSummarySnapshotsService.execute
      end.to change { PositionsSummarySnapshot.count }.by(1)
    end
  end
end