class OpenSpotOrder < ApplicationRecord
  def margin_rate
    current_price.to_f.zero? ? 0 : ((current_price - price) / current_price) * 100
  end
end
