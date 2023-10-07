class RefreshRankingSnapshotsJob < ApplicationJob
  queue_as :default

  def perform(duration, rank, data_type, source)
    data = data_type == 'weekly' ? RankingSnapshot.where("event_date >= ?", Date.yesterday - 1.week) : RankingSnapshot.where("event_date >= ?", Date.yesterday - 3.days)
    data.get_rankings(duration: duration, rank: rank, data_type: data_type, source: source)
    # 触发垃圾回收任务
    ForceGcJob.perform_later
  end
end
