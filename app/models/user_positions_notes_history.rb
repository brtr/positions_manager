class UserPositionsNotesHistory < ApplicationRecord
  belongs_to :user
  belongs_to :user_position
  has_many :attachments, dependent: :destroy

  delegate :origin_symbol, :trade_type, :source, to: :user_position

  def images=(files = [])
    return if files.blank?
    files.each do |f|
      attachments.build(image: f)
    end
  end
end
