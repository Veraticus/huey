require 'test_helper'

class RequestTest < Test::Unit::TestCase

  def setup
    super
    set_hue_ip('0.0.0.0')
  end

  [:get, :post, :put, :delete].each do |m|
    define_method("test_basic_#{m}") do
      stub_request(:any, "http://0.0.0.0/api/0123456789abdcef0123456789abcdef/")

      Huey::Request.send(m)

      assert_requested m, "0.0.0.0/api/0123456789abdcef0123456789abcdef/"
    end
  end

  def test_attempt_authentication_upon_failure
    stub_request(:get, "http://0.0.0.0/api/0123456789abdcef0123456789abcdef/").to_return(body: MultiJson.dump([{"error"=>{"type"=>1, "address"=>"/", "description"=>"unauthorized user"}}]), headers: {"Content-Type" => 'application/json'})
    stub_request(:post, "http://0.0.0.0/api").with(body: MultiJson.dump({username: '0123456789abdcef0123456789abcdef', devicetype: 'Huey'})).to_return(body: MultiJson.dump([{"error"=>{"type"=>101, "address"=>"", "description"=>"link button not pressed"}}]), headers: {"Content-Type" => 'application/json'})

    assert_raises Huey::Errors::PressLinkButton do
      Huey::Request.get
    end

    assert_requested :get, "http://0.0.0.0/api/0123456789abdcef0123456789abcdef/"
    assert_requested :post, "http://0.0.0.0/api"
  end

  def test_raises_unexpected_errors
    stub_request(:get, "http://0.0.0.0/api/0123456789abdcef0123456789abcdef/").to_return(body: MultiJson.dump([{"error"=>{"type"=>404, "address"=>"/", "description"=>"bad error!"}}]), headers: {"Content-Type" => 'application/json'})

    assert_raises Huey::Errors::HueResponseError do
      Huey::Request.get
    end

    assert_requested :get, "http://0.0.0.0/api/0123456789abdcef0123456789abcdef/"
  end
end
