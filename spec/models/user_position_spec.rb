require 'rails_helper'

RSpec.describe UserPosition, type: :model do
  let(:user) { create(:user) }
  let(:user_position) { create(:user_position, user_id: user.id) }

  it "have a valid factory" do
    expect(user_position).to be_valid
  end

  it "is valid without user id" do
    user_position.update(user_id: nil)

    expect(user_position).to be_valid
  end

  describe '#roi' do
    it 'should equal revenue divide amount' do
      expect(user_position.roi).to eq (user_position.revenue / user_position.amount)
    end
  end

  describe '#cost_ratio' do
    it 'should equal amount divide total_cost' do
      total_cost = 100
      expect(user_position.cost_ratio(total_cost)).to eq (user_position.amount / total_cost)
    end
  end
end
