require 'rails_helper'

RSpec.describe SpotBalanceHistory, type: :model do
  let(:history) { create(:spot_balance_history) }

  it "have a valid factory" do
    expect(history).to be_valid
  end
end
