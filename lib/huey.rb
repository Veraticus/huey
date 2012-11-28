require 'ipaddr'
require 'socket'
require 'eventmachine'
require 'logger'
require 'httparty'

require 'huey/version'

require 'huey/config'
require 'huey/errors'
require 'huey/ssdp'
require 'huey/request'
require 'huey/bulb'

module Huey
  extend self

  def configure
    block_given? ? yield(Huey::Config) : Huey::Config
  end
  alias :config :configure
  
  def logger
    Huey::Config.logger
  end
end