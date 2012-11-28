require 'test/unit'
require 'huey'

class SSDPTest < Test::Unit::TestCase

  # This should probably do something more intelligent eventually
  def test_hue_ip
    assert Huey::SSDP.hue_ip
  end
end