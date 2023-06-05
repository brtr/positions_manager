require 'rails_helper'

RSpec.describe UserPositionsNotesHistory, type: :model do
  let(:user) { create(:user) }
  let(:user_position) { create(:user_position) }
  let(:user_positions_notes_history) { create(:user_positions_notes_history, user: user, user_position: user_position) }

  it "have a valid factory" do
    expect(user_positions_notes_history).to be_valid
  end

  it "should equal user position's notes" do
    expect(user_positions_notes_history.notes).to eq user_position.notes
  end
end
