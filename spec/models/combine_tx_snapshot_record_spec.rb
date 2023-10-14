require 'rails_helper'

RSpec.describe CombineTxSnapshotRecord, type: :model do
  let(:snapshot) { create(:combine_tx_snapshot_record) }

  it "have a valid factory" do
    expect(snapshot).to be_valid
  end
end
