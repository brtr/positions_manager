class UserSpotBalance < ApplicationRecord
  LEVEL = %w[一级 二级 三级]

  belongs_to :user, optional: true

  enum source: [:binance, :okx, :huobi]

  def current_price
    OriginTransaction.find_by(original_symbol: origin_symbol, source: source)&.current_price
  end

  def revenue
    return 0 if current_price.nil?
    current_price * qty - amount
  end
end
