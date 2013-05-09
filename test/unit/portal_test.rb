require 'test_helper'

class PortalTest < Test::Unit::TestCase

  def test_gets_local_bridge_ip
    stub_request(:get, 'http://www.meethue.com/api/nupnp').to_return(body: MultiJson.dump([{"id" => "001788fffe0931a2", "internalipaddress" => "192.168.123.123", "macaddress" => "00:17:88:09:31:a2"}]), headers: {"Content-Type" => 'application/json'})

    assert_equal Huey::Portal.hue_ip, '192.168.123.123'

    assert_requested :get, 'http://www.meethue.com/api/nupnp'
  end

  def test_does_not_find_local_bride
    stub_request(:get, 'http://www.meethue.com/api/nupnp').to_return(body: MultiJson.dump([]), headers: {"Content-Type" => 'application/json'})

    assert_raises Huey::Errors::CouldNotFindHue do
      Huey::Portal.hue_ip
    end

    assert_requested :get, 'http://www.meethue.com/api/nupnp'
  end

end