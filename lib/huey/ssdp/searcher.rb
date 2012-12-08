# encoding: utf-8

# This code is shamelessly cribbed from the yet-unreleased upnp gem:
# https://github.com/turboladen/upnp
# I would take it more reasonably (as its own gem) but it isn't released yet, so I just stole the parts I needed.
#
# (That's also my excuse for why this has no testing.)

module Huey
  module SSDP
    class Searcher < EventMachine::Connection
      attr_reader :discovery_responses

      def initialize
        @discovery_responses = EM::Channel.new
      end

      def post_init
        if send_datagram(m_search, Huey::Config.ssdp_ip, Huey::Config.ssdp_port) > 0
          Huey.logger.debug "Sent datagram search:\n#{m_search}"
        end
      end

      def parse(data)
        new_data = {}

        data.each_line do |line|
          if match = line.match(/(\S+):(.*)/)
            key = match[1].gsub('-', '_').downcase.to_sym
            value = match[2]
            new_data[key] = value.strip
          end
        end

        new_data
      end

      def receive_data(response)
        parsed_response = parse(response)

        Huey.logger.debug "Received response: #{parsed_response}"
        return if parsed_response.has_key? :nts
        return if parsed_response[:man] && parsed_response[:man] =~ /ssdp:discover/

        @discovery_responses << parsed_response
      end

      def m_search
        <<-MSEARCH
M-SEARCH * HTTP/1.1\r
HOST: #{Huey::Config.ssdp_ip}:#{Huey::Config.ssdp_port}\r
MAN: "ssdp:discover"\r
MX: #{Huey::Config.ssdp_ttl}\r
ST: urn:schemas-upnp-org:device:Basic:1\r
\r
        MSEARCH
      end

    end
  end
end