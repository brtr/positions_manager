class MonitorSidekiqService
  class << self
    def check_enqueued_size
      busy_size = Sidekiq::Workers.new.size
      enqueued_size = Sidekiq::Stats.new.enqueued
      SlackService.send_notification(nil, enqueued_block) if (busy_size == 0 && enqueued_size >= 2)
    end

    def check_refresh_time
      time = $redis.get('get_user_positions_refresh_time').to_datetime rescue nil
      SlackService.send_notification(nil, refresh_time_block) if time && time + 24.hours < Time.current
    end

    def enqueued_block
      [
        {
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text": "*[Positions Manager]Sidekiq告警* 没有正在执行的任务但是排队中的任务大于2个"
          }
        }
      ]
    end

    def refresh_time_block
      [
        {
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text": "*[Positions Manager]Sidekiq告警* 公开仓位上次刷新时间大于24小时"
          }
        }
      ]
    end
  end
end
