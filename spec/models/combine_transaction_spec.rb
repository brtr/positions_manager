require 'rails_helper'

RSpec.describe CombineTransaction, type: :model do
  let(:combine_transaction) { create(:combine_transaction) }

  it "have a valid factory" do
    expect(combine_transaction).to be_valid
  end

  describe '#roi' do
    it 'should equal revenue divide amount' do
      expect(combine_transaction.roi).to eq (combine_transaction.revenue / combine_transaction.amount)
    end
  end

  describe '#cost_ratio' do
    it 'should equal amount divide total_cost' do
      total_cost = 100
      expect(combine_transaction.cost_ratio(total_cost)).to eq (combine_transaction.amount / total_cost)
    end
  end
end
