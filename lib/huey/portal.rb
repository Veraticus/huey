# encoding: utf-8

module Huey
  module Portal
    def self.hue_ip
      return @hue_ip if @hue_ip

      response = HTTParty.get('http://www.meethue.com/api/nupnp').first

      raise Huey::Errors::CouldNotFindHue if response.nil? || response.empty?

      @hue_ip = response['internalipaddress']
    end
  end
end
