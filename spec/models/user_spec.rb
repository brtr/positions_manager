require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { create(:user) }

  it "have a valid factory" do
    expect(user).to be_valid
  end
end
