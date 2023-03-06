require 'rails_helper'

RSpec.describe PositionsSummarySnapshot, type: :model do
  let(:positions_summary_snapshot) { create(:positions_summary_snapshot) }

  it "have a valid factory" do
    expect(positions_summary_snapshot).to be_valid
  end
end
