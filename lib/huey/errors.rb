# encoding: utf-8

module Huey
  # All the error specific to Huey.
  module Errors

    # Generic error class.
    class Error < StandardError; end

    # CouldNotFindHub is raised when no IP address can be found for Hue.
    class CouldNotFindHue < Error; end

    # PressLinkButton is raised if the link button hasn't been pressed yet.
    class PressLinkButton < Error; end

    # The bulb can't be updated since it is off
    class BulbOff < Error; end

    # Cannot add bulb to group since it is full
    class GroupTableFull < Error; end

    # Cannot make request due to missing parameters
    class MissingParameters < Error; end

    # Error occured in the bridge, not the request
    class InternalBridgeError < Error; end

    # HueResponseError is raised if we receive an odd response from the Hue.
    class HueResponseError < Error; end
  end
end
