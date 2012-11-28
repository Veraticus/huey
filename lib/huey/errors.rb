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
  end
end
