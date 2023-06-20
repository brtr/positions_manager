require 'rails_helper'

RSpec.describe CoinHoldingDuration, type: :model do
  let(:coin_holding_duration) { create(:coin_holding_duration) }

  it "have a valid factory" do
    expect(coin_holding_duration).to be_valid
  end
end
