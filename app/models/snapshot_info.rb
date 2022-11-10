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
    redis_key = "user_#{user_id}_positions_max_profit"
    total_profit = $redis.get(redis_key).to_f
    if total_profit == 0
      infos = get_infos(user_id)
      max_profit = infos.max {|a, b| a.total_profit <=> b.total_profit}
      if max_profit
        total_profit = max_profit.total_profit
        $redis.set(redis_key, total_profit, ex: 10.hours)
        $redis.set("user_#{user_id}_positions_max_profit_date", max_profit.event_date.strftime("%Y-%m-%d"), ex: 10.hours)
      end
    end
    total_profit
  end

  def self.max_loss(user_id=nil)
    redis_key = "user_#{user_id}_positions_max_loss"
    total_loss = $redis.get(redis_key).to_f
    if total_loss == 0
      infos = get_infos(user_id)
      max_loss = infos.min {|a, b| a.total_loss <=> b.total_loss}
      if max_loss
        total_loss = max_loss.total_loss
        $redis.set(redis_key, total_loss, ex: 10.hours)
        $redis.set("user_#{user_id}_positions_max_loss_date", max_loss.event_date.strftime("%Y-%m-%d"), ex: 10.hours)
      end
    end
    total_loss
  end

  def self.get_infos(user_id)
    user_id ? SnapshotInfo.where(user_id: user_id) : SnapshotInfo.where(user_id: nil)
  end
end
