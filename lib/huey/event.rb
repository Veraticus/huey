# encoding: utf-8

module Huey

  # An event encapsulates logic to send to a group, either at a certain time or arbitrarily
  class Event
    attr_accessor :group, :bulbs, :bulb, :at, :actions, :name

    def self.import(file)
      @all = []
      hash = YAML.load_file(file)

      hash.each do |key, value|
        options = {name: key}
        value.each do |k, v|
          options[k.to_sym] = v
        end

        Huey::Event.new(options)
      end
      Huey::Event.all
    end

    def self.all
      @all ||= []
    end

    def self.find(name)
      self.all.find {|s| s.name == name}
    end

    def self.execute(force = false)
      self.all.collect {|s| s.execute(force)}
    end

    def initialize(options)
      [:actions].each do |key|
        raise ArgumentError, "You must supply #{key} to create an event" unless options.keys.include?(key)

        self.instance_variable_set("@#{key}".to_sym, options[key])
      end

      self.at = options[:at]
      self.name = options[:name]
      if options[:group]
        self.group = Huey::Group.find(options[:group]) unless self.group.is_a?(Huey::Group)
      elsif options[:bulbs]
        self.bulbs = Huey::Bulb.find_all(options[:bulbs]) unless self.bulbs.is_a?(Huey::Group)
      elsif options[:bulb]
        self.bulb = Huey::Bulb.find(options[:bulb]) unless self.bulbs.is_a?(Huey::Bulb)
      else
        raise ArgumentError, "You must supply :bulb, :bulbs or :group to create an event"
      end

      self.class.all << self
    end

    def should_run?
      ((Chronic.parse(self.at) - 0.5)..(Chronic.parse(self.at) + 0.5)).cover?(Time.now)
    end

    def execute(force = false)
      target = self.group || self.bulbs || self.bulb
      target.send(:update, actions) if force || at.nil? || should_run?
    end

  end

end