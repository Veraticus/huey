# encoding: utf-8

module Huey

  # An event encapsulates logic to send to a group, either at a certain time or arbitrarily
  class Event
    attr_accessor :group, :at, :actions, :name

    def self.import(file)
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
      Huey::Event.all.find {|s| s.name == name}
    end

    def self.execute(force = false)
      Huey::Event.all.collect {|s| s.execute(force)}
    end

    def initialize(options)
      [:group, :actions].each do |key|
        raise ArgumentError, "You must supply #{key} to create an event" unless options.keys.include?(key)

        self.instance_variable_set("@#{key}".to_sym, options[key])
      end

      self.at = options[:at]
      self.name = options[:name]
      self.group = Huey::Group.find(self.group) unless self.group.is_a?(Huey::Group)

      Huey::Event.all << self
    end

    def should_run?
      ((Chronic.parse(self.at) - 0.5)..(Chronic.parse(self.at) + 0.5)).cover?(Time.now)
    end

    def execute(force = false)
      self.group.send(:update, actions) if force || at.nil? || should_run?
    end

  end

end