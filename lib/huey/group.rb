# encoding: utf-8

module Huey

  # A group is a collection of bulbs.
  class Group
    Attributes = Huey::Bulb::Attributes + [:rgb]
    attr_accessor :bulbs

    def self.import(file)
      hash = YAML.load_file(file)

      hash.each do |key, value|
        Huey::Group.new(value)
      end
      Huey::Group.all
    end

    def self.all
      @all ||= []
    end

    def initialize(*string_or_array)
      string_or_array = string_or_array.first if string_or_array.first.is_a?(Array)

      self.bulbs = if string_or_array.first.is_a?(Bulb)
        string_or_array
      else
        string_or_array.collect {|s| Huey::Bulb.find_all(s)}.flatten.uniq
      end
      
      @attributes_to_write = {}
      Huey::Group.all << self
      self
    end

    Huey::Group::Attributes.each do |attribute|
      define_method("#{attribute}=".to_sym) do |new_value|
        @attributes_to_write[attribute] = new_value
      end
    end

    def save
      response = bulbs.collect {|b| b.update(@attributes_to_write)}
      @attributes_to_write = {}
      response
    end

    def update(attrs)
      bulbs.collect {|b| b.update(attrs)}
    end

    def method_missing(meth, *args, &block)
      if !self.bulbs.empty? && self.bulbs.first.respond_to?(meth)
        h = {}
        bulbs.each {|b| h[b.id] = b.send(meth, *args, &block)}
        h
      else
        super
      end
    end
  end

end