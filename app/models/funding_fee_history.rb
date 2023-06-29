class FundingFeeHistory < ApplicationRecord
  belongs_to :snapshot_position

  delegate :revenue, to: :snapshot_position

  def self.data_summary
    amount_list = FundingFeeHistory.all.group_by(&:event_date).map{|date, value| value.sum(&:amount)}.sort
    midpoint = amount_list.size / 2.0
    median = amount_list.size.even? ? amount_list[midpoint, 2].sum / 2.0 : amount_list[midpoint]
    {
      max: amount_list.last,
      median: median,
      min: amount_list.first
    }
  end
end
