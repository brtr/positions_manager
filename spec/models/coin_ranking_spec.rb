require 'rails_helper'

RSpec.describe CoinRanking, type: :model do
  let(:coin_ranking) { create(:coin_ranking) }

  it "have a valid factory" do
    expect(coin_ranking).to be_valid
  end
end
