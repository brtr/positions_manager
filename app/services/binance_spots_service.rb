require 'binance'

class BinanceSpotsService
  attr_reader :user_id

  def initialize(user_id: nil)
    @user = User.find_by id: user_id

    if @user.present?
      @api_key = @user.api_key
      @secret_key = Base64.decode64(@user.secret_key)
    else
      @api_key = ENV["BINANCE_KEY"]
      @secret_key = ENV["BINANCE_SECRET"]
    end

    @client = Binance::Spot.new(key: @api_key, secret: @secret_key, base_url: ENV['BINANCE_SPOT_URL'])
  end

  def get_account
    @client.account
  end

  def get_open_orders
    @client.open_order_list
  end

  def get_order(symbol, order_id)
    begin
      @client.get_order(symbol: symbol, orderId: order_id)
    rescue => e
      format_error_msg(e)
    end
  end

  def send_order(payload)
    begin
      @client.new_order(**payload)
    rescue => e
      format_error_msg(e)
    end
  end

  def cancel_order(symbol, order_id)
    begin
      @client.cancel_order(symbol: symbol, orderId: order_id)
    rescue => e
      format_error_msg(e)
    end
  end

  def get_my_trades(symbol, limit: 500, from_date: 2.year.ago.to_date)
    begin
      @client.my_trades(symbol: symbol, limit: limit, startTime: from_date.to_time.to_i * 1000)
    rescue => e
      format_error_msg(e)
    end
  end

  def get_ticket(symbol)
    begin
      @client.ticker_24hr(symbol: symbol)
    rescue => e
      format_error_msg(e)
    end
  end

  def get_price(symbol)
    begin
      @client.ticker_price(symbol: symbol)
    rescue => e
      format_error_msg(e)
    end
  end

  def withdraw_histories(end_date = Date.today)
    start_date = end_date - 89.days
    begin
      @client.withdraw_history(startTime: start_date.to_time.to_i * 1000, endTime: end_date.to_time.to_i * 1000)
    rescue => e
      format_error_msg(e)
    end
  end

  def deposit_histories(end_date = Date.today)
    start_date = end_date - 89.days
    begin
      @client.deposit_history(startTime: start_date.to_time.to_i * 1000, endTime: end_date.to_time.to_i * 1000)
    rescue => e
      format_error_msg(e)
    end
  end

  private

  def format_error_msg(e)
    body = JSON.parse e.response[:body]
    "Error: #{body['msg']}"
  end
end