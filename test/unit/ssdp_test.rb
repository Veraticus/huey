require 'test_helper'

class SSDPTest < MiniTest::Test

  def setup
    Huey::SSDP.instance_variable_set(:@hue_ip, nil)
    super
  end

  def test_raises_error_with_no_ip
    searcher = mock()
    responses = mock()
    responses.stubs(:subscribe).returns(true)
    searcher.stubs(:discovery_responses).returns(responses)

    EM.expects(:open_datagram_socket).once.returns(searcher)

    assert_raises Huey::Errors::CouldNotFindHue do
      Huey::SSDP.hue_ip
    end
  end

  def test_finds_ip_correctly
    EM.expects(:open_datagram_socket).once.returns(fake_searcher)

    assert Huey::SSDP.hue_ip == '192.168.0.1'
  end

end