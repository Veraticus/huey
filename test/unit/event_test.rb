require 'test_helper'

class EventTest < MiniTest::Test

  def setup
    super
    Huey::Event.stubs(:all).returns([])

    @bulb1 = init_bulb('1', 'Living Room - TV')
    @bulb2 = init_bulb('2', 'Living Room - Fireplace')
    @bulb3 = init_bulb('3', 'Foyer')
    @bulb4 = init_bulb('4', 'Bedroom')
    Huey::Bulb.stubs(:all).returns([@bulb1, @bulb2, @bulb3, @bulb4])

    @group1 = Huey::Group.new(@bulb1, @bulb2)
    @group1.name = 'Living Room'
    @group2 = Huey::Group.new(@bulb1, @bulb2, @bulb3)
    @group3 = Huey::Group.new(@bulb3)
    @group4 = Huey::Group.new(@bulb4)
    Huey::Group.stubs(:all).returns([@group1, @group2, @group3, @group4])
  end

  def test_initializes_event
    @event = Huey::Event.new(group: @group1, at: '8PM', actions: {bri: 100, on: true})

    assert_equal @group1, @event.group
    assert_equal '8PM', @event.at
    assert_equal @event.actions, {bri: 100, on: true}
  end

  def test_initializes_event_with_name
    @event = Huey::Event.new(group: 'Living Room', at: '8PM', actions: {bri: 100, on: true})

    assert_equal @group1, @event.group
  end

  def test_executes_event
    @event = Huey::Event.new(group: @group1, at: '8PM', actions: {bri: 100, on: true})

    @group1.expects(:update).once.returns(true)

    Timecop.freeze(Chronic.parse('8PM')) do
      assert @event.should_run?
      Huey::Event.execute
    end

    Timecop.freeze(Chronic.parse('10PM')) do
      assert !@event.should_run?
      Huey::Event.execute
    end
  end

  def test_executes_event_with_some_leeway
    @event = Huey::Event.new(group: @group1, at: '8PM', actions: {bri: 100, on: true})

    @group1.expects(:update).once.returns(true)

    Timecop.freeze(Chronic.parse('8PM') - 0.3) do
      assert @event.should_run?
      Huey::Event.execute
    end

    Timecop.freeze(Chronic.parse('8PM') + 0.8) do
      assert !@event.should_run?
      Huey::Event.execute
    end
  end

  def test_force_execution
    @event = Huey::Event.new(group: @group1, at: '8PM', actions: {bri: 100, on: true})

    @group1.expects(:update).twice.returns(true)

    Timecop.freeze(Chronic.parse('10PM')) do
      assert !@event.should_run?
      @event.execute(true)
      Huey::Event.execute(true)
    end
  end

  def test_execute_event_without_schedule
    @event = Huey::Event.new(group: @group1, actions: {bri: 100, on: true})

    @group1.expects(:update).once.returns(true)

    @event.execute
  end

  def test_import_schedule_from_yaml
    Huey::Event.import('test/fixtures/events.yml')

    assert_equal 2, Huey::Event.all.count
    assert_equal 'Wakeup Call', Huey::Event.all[0].name
    assert_equal Huey::Group.find('Bedroom'), Huey::Event.all[0].group
    assert_equal '9AM', Huey::Event.all[0].at
    assert_equal Huey::Event.all[0].actions, {'bri' => 100, 'on' => true}
  end

end