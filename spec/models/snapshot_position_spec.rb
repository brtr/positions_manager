require 'rails_helper'

RSpec.describe SnapshotPosition, type: :model do
  let(:snapshot_info) { create(:snapshot_info) }
  let(:snapshot_position) { create(:snapshot_position, snapshot_info_id: snapshot_info.id) }

  it "have a valid factory" do
    expect(snapshot_position).to be_valid
  end
end
