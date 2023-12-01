class OpenSpotOrder < ApplicationRecord
  def current_price
    $redis.get("binance_spot_price_#{symbol}").to_f
  end

  def margin_rate
    current_price.zero? ? 0 : ((current_price - price) / current_price) * 100
  end
end
