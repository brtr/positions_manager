require 'rails_helper'

RSpec.describe AddingPositionsHistory, type: :model do
  let(:adding_positions_history) { create(:adding_positions_history) }

  it "have a valid factory" do
    expect(adding_positions_history).to be_valid
  end

  describe '#roi' do
    it 'should equal revenue divide amount' do
      roi = ((adding_positions_history.get_revenue / (adding_positions_history.amount.abs)) * 100).round(4)
      expect(adding_positions_history.roi).to eq (roi)
    end
  end
end
