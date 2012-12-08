require 'test/unit'
require 'webmock/test_unit'
require "mocha/setup"
require 'huey'


class Test::Unit::TestCase
  def setup
    super
    # Prevent real connections to the hub
    # EM.stubs(:open_datagram_socket).returns(fake_searcher)
  end

  def set_hue_ip(ip)
    Huey::SSDP.instance_variable_set(:@hue_ip, ip)
  end

  def fake_searcher
    searcher = mock()
    responses = mock()
    responses.stubs(:subscribe).yields({:cache_control=>"max-age=100", :ext=>"", :location=>"http://192.168.0.1:80/description.xml", :server=>"FreeRTOS/6.0.5, UPnP/1.0, IpBridge/0.1", :st=>"upnp:rootdevice", :usn=>"uuid:2f402f80-da50-11e1-9b23-0017880931a2::upnp:rootdevice"}).returns(true)
    searcher.stubs(:discovery_responses).returns(responses)
    searcher
  end
end