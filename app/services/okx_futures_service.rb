require 'openssl'
require 'rest-client'

class OkxFuturesService
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

  def get_positions
    begin
      request_path = "/api/v5/account/positions"
      do_request("get", request_path)
    rescue => e
      format_error_msg(e)
    end
  end

  def get_contract_value(instId)
    begin
      request_path = "/api/v5/public/instruments?instType=SWAP&instId=#{instId}"
      do_request("get", request_path)
    rescue => e
      format_error_msg(e)
    end
  end

  def get_orders
    begin
      request_path = "/api/v5/trade/orders-history-archive?instType=SWAP&state=filled"
      do_request("get", request_path)
    rescue => e
      format_error_msg(e)
    end
  end

  def get_pending_orders(symbol)
    request_path = "/api/v5/trade/orders-pending?instType=SWAP&instId=#{symbol}"
    response = do_request("get", request_path)
    result = get_contract_value(symbol)
    rate = result["data"][0]["ctVal"].to_f rescue 1
    response["data"].map do |order|
      {
        "side" => order["side"],
        "price" => order["px"],
        "origQty" => order["sz"].to_f * rate,
        "origType" => order["ordType"].upcase
      }
    end rescue nil
  end

  def get_24hr_tickers
    begin
      url = BASE_URL + "/api/v5/market/tickers?instType=SWAP"
      response = RestClient.get(url)
      JSON.parse(response)["data"].group_by do |d|
        symbol = d["instId"]
        from_symbol = symbol.split(/-USDT/)[0]
        from_symbol = symbol.split(/-USD/)[0] if from_symbol == symbol
        from_symbol
      end.map{|k,v| v[0]}
    rescue => e
      format_error_msg(e)
    end
  end

  def get_account
    begin
      request_path = "/api/v5/account/balance"
      do_request("get", request_path)
    rescue => e
      format_error_msg(e)
    end
  end

  def get_funding_rate(symbol, before=nil)
    begin
      request_path = "/api/v5/public/funding-rate-history?instId=#{symbol}"
      request_path += "&before=#{before}" if before
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
      "OK-ACCESS-KEY" => ENV["OKX_API_KEY"],
      "OK-ACCESS-SIGN" => sign,
      "OK-ACCESS-TIMESTAMP" => timestamp,
      "OK-ACCESS-PASSPHRASE" => ENV["OKX_PASSPHRASE"],
      "Content-Type" => "application/json",
      "accept" => "application/json"
    }

    response = RestClient.get(url, headers)
    summary = JSON.parse(response)
  end

  def signed_data(data)
    Base64.strict_encode64(OpenSSL::HMAC.digest('sha256', ENV["OKX_SECERT_KEY"], data))
  end

  def get_timestamp
    Time.now.utc.iso8601(3)
  end

  def format_error_msg(e)
    "Error: #{e}"
  end
end