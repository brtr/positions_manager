require 'openssl'
require 'rest-client'

class CoinglassService
  BASE_URL = ENV['COINGLASS_API_URL']

  class << self
    def get_top_liquidations
      begin
        request_path = "/public/v2/liquidation_top?time_type=h4"
        do_request("get", request_path)
      rescue => e
        format_error_msg(e)
      end
    end

    private
    def do_request(method, request_path)
      url = BASE_URL + request_path
      headers = {
        "coinglassSecret" => ENV["COINGLASS_API_KEY"],
        "accept" => "application/json"
      }

      response = RestClient.get(url, headers)
      summary = JSON.parse(response)
    end

    def format_error_msg(e)
      "Error: #{e}"
    end
  end
end