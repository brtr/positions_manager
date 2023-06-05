class UserPositionsNotesHistory < ApplicationRecord
  belongs_to :user
  belongs_to :user_position
end
