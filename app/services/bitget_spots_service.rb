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

  def get_orders(start_time: nil, end_time: DateTime.now)
    begin
      start_time ||= end_time - 2.weeks
      request_path = "/api/v2/tax/spot-record?endTime=#{end_time.strftime('%Q')}&startTime=#{start_time.strftime('%Q')}"
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
    timestamp = '1685013478665' #get_timestamp
    sign = signed_data("#{timestamp}#{method.upcase}#{request_path}")
    headers = {
      "ACCESS-KEY" => @api_key,
      "ACCESS-SIGN" => sign,
      "ACCESS-TIMESTAMP" => timestamp,
      "ACCESS-PASSPHRASE" => @passphrase,
      "Content-Type" => "application/json",
      "locale" => "en-US"
    }

    response = RestClient.get(url, headers)
    JSON.parse(response)
  end

  def signed_data(data)
    Base64.strict_encode64(OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), @secret_key, data))
  end

  def get_timestamp
    DateTime.now.strftime('%Q')
  end

  def format_error_msg(e)
    "Error: #{e}"
  end
end