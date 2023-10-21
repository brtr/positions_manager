class NotifyNewSymbolJob < ApplicationJob
  queue_as :daily_job

  def perform
    msgs = FetchNewSymbolService.execute
    msgs.each{|msg| SlackService.send_notification(nil, format_notice_blocks(msg))}

    check_symbol_from_api
  end

  def check_symbol_from_api
    data = BinanceFuturesService.new.get_ticker_price rescue nil
    return if data.nil?

    symbols = []
    data.each do |d|
      bp = BinancePosition.where(symbol: d['symbol']).first_or_initialize
      symbols.push(bp.symbol) if bp.new_record?
      bp.update(price: d[:price])
    end

    SlackService.send_notification(nil, format_api_blocks(symbols)) if symbols.any?
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
          "text": "*币安合约API新增币种: #{symbols.join(", ")}, 共 #{symbols.length}个*"
        }
      }
    ]
  end
end