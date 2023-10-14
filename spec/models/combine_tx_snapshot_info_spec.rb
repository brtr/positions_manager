require 'rails_helper'

RSpec.describe CombineTxSnapshotInfo, type: :model do
  let(:snapshot_info) { create(:combine_tx_snapshot_info) }

  it "have a valid factory" do
    expect(snapshot_info).to be_valid
  end
end
