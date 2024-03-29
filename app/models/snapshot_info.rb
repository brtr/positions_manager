class SnapshotInfo < ApplicationRecord
  has_many :snapshot_positions, dependent: :destroy
  belongs_to :user, optional: true

  before_create :set_columns

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

  def total_symbol_count
    increase_count + decrease_count rescue 0
  end

  def increase_ratio
    total_symbol_count.zero? ? 0 : ((increase_count / total_symbol_count.to_f) * 100).round(4)
  end

  def decrease_ratio
    total_symbol_count.zero? ? 0 : ((decrease_count / total_symbol_count.to_f) * 100).round(4)
  end

  def margin_summary
    last_info = SnapshotInfo.find_by(source_type: source_type, user_id: user_id, event_date: event_date - 1.day)
    {
      total_cost: display_number(total_cost - last_info&.total_cost.to_f),
      total_revenue: display_number(total_revenue - last_info&.total_revenue.to_f),
      profit_count: display_number(profit_count - last_info&.profit_count.to_f),
      profit_amount: display_number(profit_amount - last_info&.profit_amount.to_f),
      loss_count: display_number(loss_count - last_info&.loss_count.to_f),
      loss_amount: display_number(loss_amount - last_info&.loss_amount.to_f),
      roi: display_number(total_roi - last_info&.total_roi.to_f)
    }
  end

  def total_profit_roi
    total_cost.zero? ? 0 : ((total_profit / total_cost) * 100).round(4)
  end

  def total_loss_roi
    total_cost.zero? ? 0 : ((total_loss / total_cost) * 100).round(4)
  end

  def self.max_profit(user_id: nil, is_synced: false, date: Date.yesterday)
    redis_key = is_synced ? "user_#{user_id}_#{date.to_s}_synced_positions_max_profit" : "user_#{user_id}_#{date.to_s}_positions_max_profit"
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

  def self.max_loss(user_id: nil, is_synced: false, date: Date.yesterday)
    redis_key = is_synced ? "user_#{user_id}_#{date.to_s}_synced_positions_max_loss" : "user_#{user_id}_#{date.to_s}_positions_max_loss"
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

  def self.max_revenue(user_id: nil, is_synced: false, date: Date.yesterday)
    redis_key = is_synced ? "user_#{user_id}_#{date.to_s}_synced_positions_max_revenue" : "user_#{user_id}_#{date.to_s}_positions_max_revenue"
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

  def self.min_revenue(user_id: nil, is_synced: false, date: Date.yesterday)
    redis_key = is_synced ? "user_#{user_id}_#{date.to_s}_synced_positions_min_revenue" : "user_#{user_id}_#{date.to_s}_positions_min_revenue"
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

  def self.max_roi(user_id: nil, is_synced: false, date: Date.yesterday)
    redis_key = is_synced ? "user_#{user_id}_#{date.to_s}_synced_positions_max_roi" : "user_#{user_id}_#{date.to_s}_positions_max_roi"
    total_roi = $redis.get(redis_key).to_f
    if total_roi == 0
      infos = SnapshotInfo.where(user_id: user_id)
      infos = user_id.present? && !is_synced ? infos.uploaded : infos.synced
      max_roi = infos.max {|a, b| a.total_roi <=> b.total_roi}
      if max_roi
        total_roi = max_roi.total_roi
        $redis.set(redis_key, total_roi, ex: 10.hours)
        $redis.set("#{redis_key}_date", max_roi.event_date.strftime("%Y-%m-%d"), ex: 10.hours)
      end
    end
    total_roi.to_f
  end

  def self.min_roi(user_id: nil, is_synced: false, date: Date.yesterday)
    redis_key = is_synced ? "user_#{user_id}_#{date.to_s}_synced_positions_min_roi" : "user_#{user_id}_#{date.to_s}_positions_min_roi"
    total_roi = $redis.get(redis_key).to_f
    if total_roi == 0
      infos = SnapshotInfo.where(user_id: user_id)
      infos = user_id.present? && !is_synced ? infos.uploaded : infos.synced
      min_roi = infos.min {|a, b| a.total_roi <=> b.total_roi}
      if min_roi
        total_roi = min_roi.total_roi
        $redis.set(redis_key, total_roi, ex: 10.hours)
        $redis.set("#{redis_key}_date", min_roi.event_date.strftime("%Y-%m-%d"), ex: 10.hours)
      end
    end
    total_roi.to_f
  end

  def self.max_profit_roi(user_id: nil, is_synced: false, date: Date.yesterday)
    redis_key = is_synced ? "user_#{user_id}_#{date.to_s}_synced_positions_max_profit_roi" : "user_#{user_id}_#{date.to_s}_positions_max_profit_roi"
    total_roi = $redis.get(redis_key).to_f
    if total_roi == 0
      infos = SnapshotInfo.where(user_id: user_id)
      infos = user_id.present? && !is_synced ? infos.uploaded : infos.synced
      max_roi = infos.max {|a, b| a.total_profit_roi <=> b.total_profit_roi}
      if max_roi
        total_roi = max_roi.total_profit_roi
        $redis.set(redis_key, total_roi, ex: 10.hours)
        $redis.set("#{redis_key}_date", max_roi.event_date.strftime("%Y-%m-%d"), ex: 10.hours)
      end
    end
    total_roi.to_f
  end

  def self.max_loss_roi(user_id: nil, is_synced: false, date: Date.yesterday)
    redis_key = is_synced ? "user_#{user_id}_#{date.to_s}_synced_positions_max_loss_roi" : "user_#{user_id}_#{date.to_s}_positions_max_loss_roi"
    total_roi = $redis.get(redis_key).to_f
    if total_roi == 0
      infos = SnapshotInfo.where(user_id: user_id)
      infos = user_id.present? && !is_synced ? infos.uploaded : infos.synced
      max_roi = infos.min {|a, b| a.total_loss_roi <=> b.total_loss_roi}
      if max_roi
        total_roi = max_roi.total_loss_roi
        $redis.set(redis_key, total_roi, ex: 10.hours)
        $redis.set("#{redis_key}_date", max_roi.event_date.strftime("%Y-%m-%d"), ex: 10.hours)
      end
    end
    total_roi.to_f
  end

  private
  def display_number(num)
    num.to_f.round(2)
  end

  def set_columns
    self.total_roi = 0 if total_roi.nil?
  end
end
