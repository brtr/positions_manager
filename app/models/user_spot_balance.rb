class UserSpotBalance < ApplicationRecord
  belongs_to :user, optional: true

  enum source: [:binance, :okx, :huobi]

  def current_price
    OriginTransaction.find_by(original_symbol: origin_symbol, source: source).current_price
  end

  def revenue
    current_price * qty - amount
  end
end
