require 'rails_helper'

RSpec.describe OpenPositionOrder, type: :model do
  let(:open_position_order) { create(:open_position_order) }

  it "have a valid factory" do
    expect(open_position_order).to be_valid
  end
end
