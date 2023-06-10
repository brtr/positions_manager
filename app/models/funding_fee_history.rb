class FundingFeeHistory < ApplicationRecord
  def self.data_summary
    amount_list = FundingFeeHistory.pluck(:amount).sort
    midpoint = amount_list.size / 2.0
    median = amount_list.size.even? ? amount_list[midpoint, 2].sum / 2.0 : amount_list[midpoint]
    {
    max: amount_list.last,
    median: median,
    min: amount_list.first
    }
  end
end
