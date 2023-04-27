class UserSpotBalance < ApplicationRecord
  belongs_to :user, optional: true

  enum source: [:binance, :okx, :huobi]
end
