require 'rails_helper'

RSpec.describe OpenSpotOrder, type: :model do
  let(:open_spot_order) { create(:open_spot_order) }

  it "have a valid factory" do
    expect(open_spot_order).to be_valid
  end
end
