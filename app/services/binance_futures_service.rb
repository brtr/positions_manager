require 'openssl'
require 'rest-client'

class BinanceFuturesService
  BASE_URL = ENV['BINANCE_FUTURES_URL']

  class << self
    def get_account
      url = BASE_URL + "/fapi/v2/balance?"
      payload = {timestamp: get_timestamp}
      do_request("get", url, payload)
    end

    def get_order(symbol, order_id)
      url = BASE_URL + "/fapi/v1/order?"
      payload = {timestamp: get_timestamp, orderId: order_id, symbol: symbol}
      do_request("get", url, payload)
    end

    def send_order(payload)
      url = BASE_URL + "/fapi/v1/order"
      payload[:timestamp] = get_timestamp
      do_request("post", url, payload)
    end

    def cancel_order(symbol, order_id)
      url = BASE_URL + "/fapi/v1/order?"
      payload = {timestamp: get_timestamp, orderId: order_id, symbol: symbol}
      do_request("delete", url, payload)
    end

    def get_positions
      url = BASE_URL + "/fapi/v2/account?"
      payload = {timestamp: get_timestamp}
      do_request("get", url, payload)
    end

    def get_24hr_tickers
      url = BASE_URL + "/fapi/v1/ticker/24hr"
      response = RestClient.get(url)
      JSON.parse(response).group_by do |d|
        symbol = d["symbol"]
        from_symbol = symbol.split(/USDT/)[0]
        from_symbol = symbol.split(/BUSD/)[0] if from_symbol == symbol
        from_symbol
      end.map{|k,v| v[0]}
    end

    private
    def do_request(method, url, payload)
      sign = signed_data(build_query(payload))
      headers = {"X-MBX-APIKEY" => ENV["BINANCE_KEY"]}
      payload[:signature] = sign
      if method == "delete"
        response = RestClient.delete(url + build_query(payload), headers)
      elsif method == "post"
        response = RestClient.post(url, build_query(payload), headers)
      else
        response = RestClient.get(url + build_query(payload), headers)
      end
      summary = JSON.parse(response)
    end

    def signed_data(data)
      OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), ENV["BINANCE_SECRET"], data)
    end

    def get_timestamp
      DateTime.now.strftime('%Q')
    end

    def build_query(params)
      params.map do |key, value|
        if value.is_a?(Array)
          value.map { |v| "#{key}=#{v}" }.join('&')
        else
          "#{key}=#{value}"
        end
      end.join('&')
    end

    def format_error_msg(e)
      body = JSON.parse e.response[:body]
      "Error: #{body['msg']}"
    end
  end
end