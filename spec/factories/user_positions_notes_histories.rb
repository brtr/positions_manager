FactoryBot.define do
  factory :user_positions_notes_history do
    user
    user_position
    notes { 'this is a test note' }
  end
end
