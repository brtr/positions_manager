require 'openssl'
require 'rest-client'

class BitgetSpotsService
  BASE_URL = ENV['BITGET_API_URL']
  attr_reader :user_id

  def initialize(user_id: nil)
    @user = User.find_by id: user_id

    if @user.present?
      @api_key = @user.bitget_api_key
      @secret_key = Base64.decode64(@user.bitget_secret_key) rescue nil
      @passphrase = Base64.decode64(@user.bitget_passphrase) rescue nil
    else
      @api_key = ENV["BITGET_KEY"]
      @secret_key = ENV["BITGET_SECRET"]
      @passphrase = ENV["BITGET_PASSPHRASE"]
    end
  end

  def get_orders
    begin
      request_path = "/api/v2/spot/trade/history-orders"
      do_request("get", request_path)
    rescue => e
      format_error_msg(e)
    end
  end

  def get_price(symbol)
    begin
      request_path = "/api/v2/spot/market/tickers?symbol=#{symbol}"
      url = BASE_URL + request_path
      response = RestClient.get(url)
      JSON.parse(response)
    rescue => e
      format_error_msg(e)
    end
  end

  private
  def do_request(method, request_path)
    url = BASE_URL + request_path
    timestamp = get_timestamp
    sign = signed_data("#{timestamp}#{method.upcase}#{request_path}")
    headers = {
      "ACCESS-KEY" => @api_key,
      "ACCESS-SIGN" => sign,
      "ACCESS-TIMESTAMP" => timestamp,
      "ACCESS-PASSPHRASE" => @passphrase,
      "Content-Type" => "application/json",
      "locale" => "zh-CN"
    }

    begin
      response = RestClient.get(url, headers)
    rescue RestClient::ExceptionWithResponse => e
      e.response
    end
    JSON.parse(response)
  end

  def signed_data(data)
    Base64.strict_encode64(OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), @secret_key, data))
  end

  def get_timestamp
    DateTime.now.strftime('%Q').to_i
  end

  def format_error_msg(e)
    "Error: #{e}"
  end
end