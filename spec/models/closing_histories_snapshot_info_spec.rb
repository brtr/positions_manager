require 'rails_helper'

RSpec.describe ClosingHistoriesSnapshotInfo, type: :model do
  let(:snapshot_info) { create(:closing_histories_snapshot_info) }

  it "have a valid factory" do
    expect(snapshot_info).to be_valid
  end
end
