require 'openssl'
require 'rest-client'
require "addressable/uri"

class HuobiFuturesService
  BASE_URL = ENV['HUOBI_FUTURES_URL']

  class << self
    def get_positions
      path = "/linear-swap-api/v1/swap_cross_position_info"
      payload = {
        "AccessKeyId" => ENV["HUOBI_ACCESS_KEY"],
        "SignatureMethod" => "HmacSHA256",
        "SignatureVersion" => 2,
        "Timestamp" => get_timestamp
      }
      payload["Signature"] = signed_data(build_query(payload), path)
      headers = {'Accept' => 'application/json', 'Content-type' => 'application/json'}
      url = BASE_URL + path + "?" + build_query(payload)
      response = RestClient.post(url, nil, headers)
      JSON.parse(response)
    end

    private

    def signed_data(data, path)
      data = "POST\napi.hbdm.vn\n" + path + "\n" + data
      Base64.encode64(OpenSSL::HMAC.digest('sha256', ENV["HUOBI_SECRET_KEY"], data)).gsub("\n","")
    end

    def get_timestamp
      Time.now.getutc.strftime("%Y-%m-%dT%H:%M:%S")
    end

    def build_query(params)
      return params unless params.is_a? Hash
      uri               =   Addressable::URI.new
      uri.query_values  =   params
      uri.query
    end
  end
end