# encoding: utf-8

module Huey

  # Wraps requests to the actual Hue itself
  class Request
    class << self

      [:get, :post, :put, :delete].each do |method|
        define_method(method) do |url = '', options = {}|
          response = HTTParty.send(method, "http://#{Huey::SSDP.hue_ip}/api/#{Huey::Config.uuid}/#{url}", options).parsed_response

          if self.error?(response, 1)
            self.register
            return self.send(method, url, options) 
          end

          response
        end
      end

      def register
        response = HTTParty.post("http://#{Huey::SSDP.hue_ip}/api", body: MultiJson.dump({username: Huey::Config.uuid, devicetype: 'Huey'})).parsed_response

        raise Huey::Errors::PressLinkButton, 'Press the link button and try your request again' if self.error?(response, 101)

        response
      end

      def error?(response, type)
        if response.is_a?(Array) && response.first['error']
          if response.first['error']['type'] == type
            true
          else
            raise Huey::Errors::HueResponseError, response
          end
        end
      end

    end

  end
end