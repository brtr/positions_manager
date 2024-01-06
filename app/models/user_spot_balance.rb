class UserSpotBalance < ApplicationRecord
  LEVEL = %w[一级 二级 三级]

  belongs_to :user, optional: true

  scope :available, -> { where("qty > 0") }

  enum source: [:binance, :okx, :huobi, :gate]

  def current_price
    OriginTransaction.find_by(original_symbol: origin_symbol, source: source)&.current_price
  end

  def revenue
    return 0 if current_price.nil?
    current_price * qty - amount
  end

  def roi
    revenue / amount
  end

  def self.summary
    data = UserSpotBalance.available

    {
      total_cost: data.sum(&:amount),
      total_revenue: data.sum(&:revenue)
    }
  end

  def self.actual_balance(user_id=nil)
    redis_key = "user_#{user_id}_spot_balance"
    data = JSON.parse($redis.get(redis_key)) rescue nil
    if data.nil?
      data = BinanceSpotsService.new.get_account[:balances] rescue nil

      $redis.set(redis_key, data.to_json, ex: 1.hour)
    end
    data
  end
end
