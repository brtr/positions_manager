class SnapshotInfo < ApplicationRecord
  has_many :snapshot_positions, dependent: :destroy
  belongs_to :user, optional: true

  def total_profit
    snapshot_positions.profit.sum(&:revenue)
  end

  def total_loss
    snapshot_positions.loss.sum(&:revenue)
  end

  def self.max_profit(user_id=nil)
    redis_key = user_id ? "user_#{user_id}_positions_max_profit" : 'user_positions_max_profit'
    max_profit = $redis.get(redis_key).to_f
    if max_profit == 0
      infos = get_infos(user_id)
      max_profit = infos.max {|a, b| a.total_profit <=> b.total_profit}.total_profit rescue 0
      $redis.set(redis_key, max_profit, ex: 20.hours)
    end
    max_profit
  end

  def self.max_loss(user_id=nil)
    redis_key = user_id ? "user_#{user_id}_positions_max_loss" : 'user_positions_max_loss'
    max_loss = $redis.get(redis_key).to_f
    if max_loss == 0
      infos = get_infos(user_id)
      max_loss = infos.min {|a, b| a.total_loss <=> b.total_loss}.total_loss rescue 0
      $redis.set(redis_key, max_loss, ex: 20.hours)
    end
    max_loss
  end

  def self.get_infos(user_id)
    user_id ? SnapshotInfo.where(user_id: user_id) : SnapshotInfo.where(user_id: nil)
  end
end
