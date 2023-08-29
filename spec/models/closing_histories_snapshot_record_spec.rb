require 'rails_helper'

RSpec.describe ClosingHistoriesSnapshotRecord, type: :model do
  let(:snapshot_info) { create(:closing_histories_snapshot_info) }
  let(:snapshot_position) { create(:closing_histories_snapshot_record, closing_histories_snapshot_info_id: snapshot_info.id) }

  it "have a valid factory" do
    expect(snapshot_position).to be_valid
  end
end
