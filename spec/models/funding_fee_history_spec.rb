require 'rails_helper'

RSpec.describe FundingFeeHistory, type: :model do
  let(:funding_fee_history) { create(:funding_fee_history) }

  it "have a valid factory" do
    expect(funding_fee_history).to be_valid
  end
end
