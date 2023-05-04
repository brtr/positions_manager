require 'rails_helper'

RSpec.describe SpotBalanceSnapshotRecord, type: :model do
  let(:snapshot_info) { create(:spot_balance_snapshot_info) }
  let(:snapshot_position) { create(:spot_balance_snapshot_record, spot_balance_snapshot_info_id: snapshot_info.id) }

  it "have a valid factory" do
    expect(snapshot_position).to be_valid
  end
end
