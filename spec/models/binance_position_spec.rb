require 'rails_helper'

RSpec.describe BinancePosition, type: :model do
  let(:binance_position) { create(:binance_position) }

  it "have a valid factory" do
    expect(binance_position).to be_valid
  end
end
