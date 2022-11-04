require 'openssl'
require 'rest-client'

class OkxFuturesService
  BASE_URL = ENV['OKX_FUTURES_URL']

  class << self
    def get_positions
      begin
        request_path = "/api/v5/account/positions"
        do_request("get", request_path)
      rescue => e
        format_error_msg(e)
      end
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
end