class PositionsSummarySnapshot < ApplicationRecord
  def self.get_roi_summary
    roi_list = PositionsSummarySnapshot.all.map do |info|
                ((info.total_revenue / info.total_cost) * 100).round(3)
               end.sort
    midpoint = roi_list.size / 2.0
    median = roi_list.size.even? ? roi_list[midpoint, 2].sum / 2.0 : roi_list[midpoint]
    {
      max: roi_list.last,
      median: median,
      min: roi_list.first
    }
  end
end
