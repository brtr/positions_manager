require 'rails_helper'

RSpec.describe UserSpotBalance, type: :model do
  let(:user) { create(:user) }
  let(:user_spot_balance) { create(:user_spot_balance, user_id: user.id) }

  it "have a valid factory" do
    expect(user_spot_balance).to be_valid
  end

  it "is valid without user id" do
    user_spot_balance.update(user_id: nil)

    expect(user_spot_balance).to be_valid
  end
end
