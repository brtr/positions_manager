require 'rails_helper'

RSpec.describe UserSyncedPosition, type: :model do
  let(:user) { create(:user) }
  let(:user_synced_position) { create(:user_synced_position, user_id: user.id) }

  it "have a valid factory" do
    expect(user_synced_position).to be_valid
  end

  describe '#roi' do
    it 'should equal revenue divide amount' do
      expect(user_synced_position.roi).to eq (user_synced_position.revenue / user_synced_position.amount)
    end
  end

  describe '#cost_ratio' do
    it 'should equal amount divide total_cost' do
      total_cost = 100
      expect(user_synced_position.cost_ratio(total_cost)).to eq (user_synced_position.amount / total_cost)
    end
  end
end
