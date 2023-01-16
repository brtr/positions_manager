require 'rails_helper'

RSpec.describe RankingSnapshot, type: :model do
  let(:ranking_snapshot) { create(:ranking_snapshot) }

  it "is valid with valid attributes" do
    expect(ranking_snapshot).to be_valid
  end
end
