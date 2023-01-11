require 'rails_helper'

RSpec.describe SyncedTransaction, type: :model do
  let(:synced_transaction) { create(:synced_transaction) }

  it "have a valid factory" do
    expect(synced_transaction).to be_valid
  end

end
