class MonitorSidekiqService
  class << self
    def execute
      busy_size = Sidekiq::Workers.new.size
      enqueued_size = Sidekiq::Stats.new.enqueued
      SlackService.send_notification(nil, format_block) if busy_size == 0 && enqueued_size >= 2
    end

    def format_block
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
  end
end
