require 'rails_helper'

RSpec.describe AddingPositionsHistory, type: :model do
  let(:adding_positions_history) { create(:adding_positions_history) }

  it "have a valid factory" do
    expect(adding_positions_history).to be_valid
  end
end
