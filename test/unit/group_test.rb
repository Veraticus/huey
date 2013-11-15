require 'test_helper'

class GroupTest < MiniTest::Test

  def setup
    super
    Huey::Group.stubs(:all).returns([])

    @bulb1 = init_bulb('1', 'Living Room - TV')
    @bulb2 = init_bulb('2', 'Living Room - Fireplace')
    @bulb3 = init_bulb('3', 'Foyer')
    @bulb4 = init_bulb('4', 'Bedroom')

    Huey::Bulb.stubs(:all).returns([@bulb1, @bulb2, @bulb3, @bulb4])
  end

  def test_initializes_group_from_bulbs
    @group = Huey::Group.new(@bulb1, @bulb2, @bulb3)

    assert_equal [@bulb1, @bulb2, @bulb3], @group.bulbs
  end

  def test_initializes_group_from_name
    @group = Huey::Group.new('Living Room')

    assert_equal [@bulb1, @bulb2], @group.bulbs
  end

  def test_initialzes_group_from_names
    @group = Huey::Group.new('Living Room', 'Foyer')

    assert_equal [@bulb1, @bulb2, @bulb3], @group.bulbs
  end

  def test_initializes_groups_from_yml
    Huey::Group.import('test/fixtures/groups.yml')

    assert_equal 3, Huey::Group.all.count
    assert_equal [@bulb1, @bulb2], Huey::Group.all[0].bulbs
    assert_equal [@bulb3], Huey::Group.all[1].bulbs
    assert_equal [@bulb4], Huey::Group.all[2].bulbs
  end

  def test_find_group_by_name
    g = Huey::Group.new('Living Room')
    g.name = 'Living Room'

    assert_equal g, Huey::Group.find('Living Room')
  end

  def test_not_included_in_all_if_empty
    g = Huey::Group.new

    assert !Huey::Group.all.include?(g)
  end

  def test_delegates_save_to_bulbs
    @group = Huey::Group.new(@bulb1, @bulb2, @bulb3)

    [@bulb1, @bulb2, @bulb3].each do |bulb|
      Huey::Request.expects(:put).with("lights/#{bulb.id}/state", body: MultiJson.dump({on: true, bri: 100})).once.returns(true)
    end

    @group.on = true
    @group.bri = 100
    @group.save

    [@bulb1, @bulb2, @bulb3].each do |bulb|
      assert_equal true, bulb.on
      assert_equal 100, bulb.bri
    end
  end

  def test_delegates_update_to_bulbs
    @group = Huey::Group.new(@bulb1, @bulb2, @bulb3)

    [@bulb1, @bulb2, @bulb3].each do |bulb|
      Huey::Request.expects(:put).with("lights/#{bulb.id}/state", body: MultiJson.dump({on: true, bri: 100})).once.returns(true)
    end

    @group.update(on: true, bri: 100)

    [@bulb1, @bulb2, @bulb3].each do |bulb|
      assert_equal true, bulb.on
      assert_equal 100, bulb.bri
    end
  end

  def test_returns_all_bulb_attrs_for_method_missing
    @group = Huey::Group.new(@bulb1, @bulb2, @bulb3)

    assert_equal @group.bri, {1=>127, 2=>127, 3=>127}
  end

  def test_implements_each
    @group = Huey::Group.new(@bulb1, @bulb2, @bulb3)

    [@bulb1, @bulb2, @bulb3].each do |bulb|
      Huey::Request.expects(:put).with("lights/#{bulb.id}/state", body: MultiJson.dump({on: true, bri: 101})).once.returns(true)
    end


    @group.each {|bulb| bulb.update(on: true, bri: 101)}

    [@bulb1, @bulb2, @bulb3].each do |bulb|
      assert_equal true, bulb.on
      assert_equal 101, bulb.bri
    end
  end

  def test_includes_enumerable
    @group = Huey::Group.new(@bulb1, @bulb2, @bulb3)

    [@bulb1, @bulb2, @bulb3].each do |bulb|
      Huey::Request.expects(:put).with("lights/#{bulb.id}/state", body: MultiJson.dump({on: true, bri: 102})).once.returns(true)
    end

    assert_equal [true, true, true], @group.collect {|bulb| bulb.update(on: true, bri: 102)}
  end
end