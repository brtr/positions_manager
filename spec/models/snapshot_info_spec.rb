require 'rails_helper'

RSpec.describe SnapshotInfo, type: :model do
  let(:user) { create(:user) }
  let(:snapshot_info) { create(:snapshot_info, user_id: user.id) }

  it "have a valid factory" do
    expect(snapshot_info).to be_valid
  end

  it "is valid without user id" do
    snapshot_info.update(user_id: nil)

    expect(snapshot_info).to be_valid
  end
end
