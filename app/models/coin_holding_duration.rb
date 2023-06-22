class CoinHoldingDuration < ApplicationRecord
  scope :finished, -> { where('duration > 0') }

  def self.average_durations
    data = CoinHoldingDuration.finished.where(user_id: nil)
    return 0 if data.blank?
    data.sum(&:duration).to_f / data.count
  end
end
