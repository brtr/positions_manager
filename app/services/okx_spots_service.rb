require 'openssl'
require 'rest-client'

class OkxSpotsService
  BASE_URL = ENV['OKX_FUTURES_URL']
  attr_reader :user_id

  def initialize(user_id: nil)
    @user = User.find_by id: user_id

    if @user.present?
      @api_key = @user.okx_api_key
      @secret_key = Base64.decode64(@user.okx_secret_key)
      @passphrase = Base64.decode64(@user.okx_passphrase)
    else
      @api_key = ENV["OKX_API_KEY"]
      @secret_key = ENV["OKX_SECERT_KEY"]
      @passphrase = ENV["OKX_PASSPHRASE"]
    end
  end

  def get_orders
    begin
      request_path = "/api/v5/trade/orders-history-archive?instType=SPOT&state=filled"
      do_request("get", request_path)
    rescue => e
      format_error_msg(e)
    end
  end

  def get_price(instId)
    begin
      request_path = "/api/v5/market/ticker?instId=#{instId}"
      do_request("get", request_path)
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
      "OK-ACCESS-KEY" => @api_key,
      "OK-ACCESS-SIGN" => sign,
      "OK-ACCESS-TIMESTAMP" => timestamp,
      "OK-ACCESS-PASSPHRASE" => @passphrase,
      "Content-Type" => "application/json",
      "accept" => "application/json"
    }

    response = RestClient.get(url, headers)
    summary = JSON.parse(response)
  end

  def signed_data(data)
    Base64.strict_encode64(OpenSSL::HMAC.digest('sha256', @secret_key, data))
  end

  def get_timestamp
    Time.now.utc.iso8601(3)
  end

  def format_error_msg(e)
    "Error: #{e}"
  end
end