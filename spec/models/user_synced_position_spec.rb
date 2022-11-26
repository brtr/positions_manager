require 'rails_helper'

RSpec.describe UserSyncedPosition, type: :model do
  let(:user) { create(:user) }
  let(:user_synced_position) { create(:user_synced_position, user_id: user.id) }

  it "have a valid factory" do
    expect(user_synced_position).to be_valid
  end
end
