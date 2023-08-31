require 'rails_helper'

RSpec.describe WalletHistory, type: :model do
  let(:wallet_history) { create(:wallet_history) }

  it "have a valid factory" do
    expect(wallet_history).to be_valid
  end
end
