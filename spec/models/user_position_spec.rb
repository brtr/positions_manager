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
end
