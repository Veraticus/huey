# encoding: utf-8

# This code is shamelessly cribbed from the yet-unreleased upnp gem:
# https://github.com/turboladen/upnp
# I would take it more reasonably (as its own gem) but it isn't released yet, so I just stole the parts I needed.

require 'huey/ssdp/searcher'

module Huey
  module SSDP
    def self.hue_ip
      return @hue_ip if @hue_ip

      multicast_searcher = proc do
        EM.open_datagram_socket('0.0.0.0', 0, Huey::SSDP::Searcher)
      end

      responses = []

      EM.run do
        ms = multicast_searcher.call

        ms.discovery_responses.subscribe do |notification|
          responses << notification
        end

        EM.add_timer(Huey::Config.ssdp_ttl) { EM.stop }
        trap('INT') { EM.stop }
        trap('TERM') { EM.stop }
        trap('HUP')  { EM.stop }
      end

      raise Huey::Errors::CouldNotFindHue, 'No IP address found for the Hue hub' unless responses.first

      @hue_ip = responses.first[:location].match(/http:\/\/(.*?):(.*?)\//)[1]
    end
  end
end