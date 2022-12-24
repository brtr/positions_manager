require 'rails_helper'

RSpec.describe OriginTransaction, type: :model do
  let(:origin_transaction) { create(:origin_transaction) }

  it "have a valid factory" do
    expect(origin_transaction).to be_valid
  end

  describe '#roi' do
    it 'should equal revenue divide amount' do
      expect(origin_transaction.roi).to eq (origin_transaction.revenue / origin_transaction.amount)
    end
  end

  describe '#cost_ratio' do
    it 'should equal amount divide total_cost' do
      total_cost = 100
      expect(origin_transaction.cost_ratio(total_cost)).to eq (origin_transaction.amount / total_cost)
    end
  end
end
