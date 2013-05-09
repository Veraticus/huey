require 'test/unit'
require 'webmock/test_unit'
require "mocha/setup"
require 'timecop'
require 'huey'

class Test::Unit::TestCase
  def setup
    super
    # Prevent real connections to the hub
    EM.stubs(:open_datagram_socket).returns(fake_searcher)
  end

  def set_hue_ip(ip)
    Huey::Request.stubs(:hue_ip).returns(ip)
  end

  def fake_searcher
    searcher = mock()
    responses = mock()
    responses.stubs(:subscribe).yields({:cache_control=>"max-age=100", :ext=>"", :location=>"http://192.168.0.1:80/description.xml", :server=>"FreeRTOS/6.0.5, UPnP/1.0, IpBridge/0.1", :st=>"upnp:rootdevice", :usn=>"uuid:2f402f80-da50-11e1-9b23-0017880931a2::upnp:rootdevice"}).returns(true)
    searcher.stubs(:discovery_responses).returns(responses)
    searcher
  end

  def light_response(id = "1", name = "Living Room")
    {id => {"state"=>{"on"=>false, "bri"=>127, "hue"=>54418, "sat"=>158, "xy"=>[0.509, 0.4149], "ct"=>459, "alert"=>"none", "effect"=>"none", "colormode"=>"hue", "reachable"=>true}, "type"=>"Extended color light", "name"=>name, "modelid"=>"LCT001", "swversion"=>"65003148", "pointsymbol"=>{"1"=>"none", "2"=>"none", "3"=>"none", "4"=>"none", "5"=>"none", "6"=>"none", "7"=>"none", "8"=>"none"}}}
  end

  def init_bulb(id = "1", name = "Living Room")
    light = light_response(id, name)
    Huey::Bulb.new(light.keys.first, light.values.first)
  end

end