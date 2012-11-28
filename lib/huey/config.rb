# encoding: utf-8
require "huey/config/options"

module Huey #:nodoc

  # Contains all the basic configuration information required for huey.
  module Config
    extend self
    extend Options

    # All the default options.
    option :ssdp_ip, default: '239.255.255.250'
    option :ssdp_port, default: 1900
    option :ssdp_ttl, default: 1
    option :uuid, default: '0123456789abdcef0123456789abcdef'

    # The default logger for Huey: either the Rails logger or just stdout.
    #
    # @since 0.0.1
    def default_logger
      defined?(Rails) && Rails.respond_to?(:logger) ? Rails.logger : ::Logger.new($stdout)
    end

    # Returns the assigned logger instance.
    #
    # @since 0.0.1
    def logger
      @logger ||= default_logger
    end

    # If you want to, set the logger manually to any output you'd like. Or pass false or nil to disable logging entirely.
    #
    # @since 0.0.1
    def logger=(logger)
      case logger
      when false, nil then @logger = nil
      when true then @logger = default_logger
      else
        @logger = logger if logger.respond_to?(:info)
      end
    end

  end
end
