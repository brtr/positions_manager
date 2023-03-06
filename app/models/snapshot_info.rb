class SnapshotInfo < ApplicationRecord
  has_many :snapshot_positions, dependent: :destroy
  belongs_to :user, optional: true

  enum source_type: [:synced, :uploaded]

  def total_profit
    snapshot_positions.profit.sum(&:revenue)
  end

  def total_loss
    snapshot_positions.loss.sum(&:revenue)
  end

  def total_revenue
    snapshot_positions.sum(&:revenue)
  end

  def self.max_profit(user_id=nil, is_synced=false)
    redis_key = is_synced ? "user_#{user_id}_synced_positions_max_profit" : "user_#{user_id}_positions_max_profit"
    total_profit = $redis.get(redis_key).to_f
    if total_profit == 0
      infos = SnapshotInfo.where(user_id: user_id)
      infos = user_id.present? && !is_synced ? infos.uploaded : infos.synced
      max_profit = infos.max {|a, b| a.total_profit <=> b.total_profit}
      if max_profit
        total_profit = max_profit.total_profit
        $redis.set(redis_key, total_profit, ex: 10.hours)
        $redis.set("#{redis_key}_date", max_profit.event_date.strftime("%Y-%m-%d"), ex: 10.hours)
      end
    end
    total_profit
  end

  def self.max_loss(user_id=nil, is_synced=false)
    redis_key = is_synced ? "user_#{user_id}_synced_positions_max_loss" : "user_#{user_id}_positions_max_loss"
    total_loss = $redis.get(redis_key).to_f
    if total_loss == 0
      infos = SnapshotInfo.where(user_id: user_id)
      infos = user_id.present? && !is_synced ? infos.uploaded : infos.synced
      max_loss = infos.min {|a, b| a.total_loss <=> b.total_loss}
      if max_loss
        total_loss = max_loss.total_loss
        $redis.set(redis_key, total_loss, ex: 10.hours)
        $redis.set("#{redis_key}_date", max_loss.event_date.strftime("%Y-%m-%d"), ex: 10.hours)
      end
    end
    total_loss
  end

  def self.max_revenue(user_id=nil, is_synced=false)
    redis_key = is_synced ? "user_#{user_id}_synced_positions_max_revenue" : "user_#{user_id}_positions_max_revenue"
    total_revenue = $redis.get(redis_key).to_f
    if total_revenue == 0
      infos = SnapshotInfo.where(user_id: user_id)
      infos = user_id.present? && !is_synced ? infos.uploaded : infos.synced
      max_revenue = infos.max {|a, b| a.total_revenue <=> b.total_revenue}
      if max_revenue
        total_revenue = max_revenue.total_revenue
        $redis.set(redis_key, total_revenue, ex: 10.hours)
        $redis.set("#{redis_key}_date", max_revenue.event_date.strftime("%Y-%m-%d"), ex: 10.hours)
      end
    end
    total_revenue
  end

  def self.min_revenue(user_id=nil, is_synced=false)
    redis_key = is_synced ? "user_#{user_id}_synced_positions_min_revenue" : "user_#{user_id}_positions_min_revenue"
    total_revenue = $redis.get(redis_key).to_f
    if total_revenue == 0
      infos = SnapshotInfo.where(user_id: user_id)
      infos = user_id.present? && !is_synced ? infos.uploaded : infos.synced
      min_revenue = infos.min {|a, b| a.total_revenue <=> b.total_revenue}
      if min_revenue
        total_revenue = min_revenue.total_revenue
        $redis.set(redis_key, total_revenue, ex: 10.hours)
        $redis.set("#{redis_key}_date", min_revenue.event_date.strftime("%Y-%m-%d"), ex: 10.hours)
      end
    end
    total_revenue
  end
end
