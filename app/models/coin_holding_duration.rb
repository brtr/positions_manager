class CoinHoldingDuration < ApplicationRecord
  scope :finished, -> { where('duration > 0') }

  def self.average_durations
    data = CoinHoldingDuration.finished.where(user_id: nil)
    data.sum(&:duration).to_f / data.count
  end
end
