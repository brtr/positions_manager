require 'rails_helper'

RSpec.describe CoinDataHistory, type: :model do
  let(:coin_data_history) { create(:coin_data_history) }

  it "have a valid factory" do
    expect(coin_data_history).to be_valid
  end
end
