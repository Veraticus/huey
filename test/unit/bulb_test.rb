require 'test_helper'

class BulbTest < Test::Unit::TestCase

  def setup
    super
    @bulb = init_bulb
  end

  def test_initializes_bulb_from_hash
    assert_equal @bulb.name, "Living Room"
    assert_equal @bulb.id, 1
    assert_equal @bulb.hue, 54418
  end

  def test_initializes_all_bulbs
    Huey::Request.expects(:get).once.returns('lights' => light_response.merge(light_response('2', 'Bedroom')))

    assert Huey::Bulb.all
    assert_equal Huey::Bulb.all.first.id, 1
    assert_equal Huey::Bulb.all.last.id, 2
  end

  def test_send_alert_to_bulb
    Huey::Request.expects(:put).with("lights/1/state", body: MultiJson.dump({alert: 'select'})).once.returns(true)

    @bulb.alert!
  end

  def test_bulb_get_attributes
    Huey::Bulb::ATTRIBUTES.each do |attr|
      assert @bulb.respond_to?(attr), "#{attr} is not set"
      assert @bulb.instance_variable_defined?("@#{attr}".to_sym), "#{attr} has no instance variable"
    end
  end

  def test_bulb_set_attributes
    assert @bulb.instance_variable_defined?(:@changes), "@changes has no instance variable"

    Huey::Bulb::ATTRIBUTES.each do |attr|
      assert @bulb.respond_to?("#{attr}="), "#{attr} is not set" unless attr == :colormode
    end
  end

  def test_send_changes_on_save
    Huey::Request.expects(:put).with("lights/1/state", body: MultiJson.dump({on: true, bri: 100})).once.returns(true)

    @bulb.on = true
    @bulb.bri = 100
    assert @bulb.save
  end

  def test_only_different_changes_on_save
    Huey::Request.expects(:put).with("lights/1/state", body: MultiJson.dump({bri: 100})).once.returns(true)

    @bulb.on = false
    @bulb.bri = 100
    assert @bulb.save
  end

  def test_update_attributes_simultaneously
    Huey::Request.expects(:put).with("lights/1/state", body: MultiJson.dump({on: true, bri: 100})).once.returns(true)

    assert @bulb.update(on: true, bri: 100)
  end

  def test_get_html_color
    assert_equal '#cb30ce', @bulb.rgb
  end

  def test_set_html_color
    @bulb.rgb = '#8FF1F5'

    assert_equal 33196, @bulb.hue
    assert_equal 106, @bulb.sat
    assert_equal 245, @bulb.bri
  end

end