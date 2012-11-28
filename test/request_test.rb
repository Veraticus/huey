require 'test/unit'
require 'huey'

class RequestTest < Test::Unit::TestCase

  def test_get
    assert Huey::Request.get
  end
end