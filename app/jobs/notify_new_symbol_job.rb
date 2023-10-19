class NotifyNewSymbolJob < ApplicationJob
  queue_as :daily_job

  def perform
    msgs = FetchNewSymbolService.execute
    msgs.each{|msg| SlackService.send_notification(nil, format_notice_blocks(msg))}

    check_symbol_from_api
  end

  def check_symbol_from_api
    symbols = BinanceFuturesService.new.get_ticker_price.map{|x| x['symbol']} rescue []
    return if symbols.empty?

    redis_key = 'binance_futures_symbols'
    prev_symbols = JSON.parse($redis.get(redis_key)) rescue []
    diff_symbols = symbols - prev_symbols
    $redis.set(redis_key, symbols)
    SlackService.send_notification(nil, format_blocks(diff_symbols)) if diff_symbols.any?
  end

  def format_notice_blocks(msg)
    [
      {
        "type": "section",
        "text": {
          "type": "mrkdwn",
          "text": "*#{msg}*"
        }
      }
    ]
  end

  def format_api_blocks(symbols)
    [
      {
        "type": "section",
        "text": {
          "type": "mrkdwn",
          "text": "*币安合约API新增币种: #{symbols.join(", ")}, 共#{symbols.length}个*"
        }
      }
    ]
  end
end