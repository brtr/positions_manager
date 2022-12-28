require 'rails_helper'

RSpec.describe TransactionsSnapshotInfo, type: :model do
  let(:snapshot_info) { create(:transactions_snapshot_info) }

  it "have a valid factory" do
    expect(snapshot_info).to be_valid
  end
end
