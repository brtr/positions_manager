require 'rails_helper'

RSpec.describe TransactionsSnapshotRecord, type: :model do
  let(:snapshot_info) { create(:transactions_snapshot_info) }
  let(:snapshot_record) { create(:transactions_snapshot_record, transactions_snapshot_info_id: snapshot_info.id) }

  it "have a valid factory" do
    expect(snapshot_record).to be_valid
  end
end
