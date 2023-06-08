class UserPositionsNotesHistory < ApplicationRecord
  belongs_to :user
  belongs_to :user_position

  delegate :origin_symbol, :trade_type, :source, to: :user_position
end
