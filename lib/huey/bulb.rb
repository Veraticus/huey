# encoding: utf-8

module Huey

  # An actual object for a bulb.
  class Bulb
    Attributes = [:on, :bri, :hue, :sat, :xy, :ct, :name]
    attr_reader :id

    def self.all
      @all ||= Huey::Request.get['lights'].collect do |id, hash|
        Bulb.new(id, hash)
      end
    end

    def self.find(id)
      self.all.find {|b| b.id == id || b.name == id}
    end

    def initialize(id, hash)
      @id = id.to_i
      @changes = {}
      @name = hash['name']

      (Huey::Bulb::Attributes - [:name]).each do |attribute|
        instance_variable_set("@#{attribute}".to_sym, hash['state'][attribute.to_s])
      end
    end

    Huey::Bulb::Attributes.each do |attribute|
      define_method(attribute) do
        instance_variable_get("@#{attribute}".to_sym)
      end

      define_method("#{attribute}=".to_sym) do |new_value|
        return true if self.send(attribute) == new_value

        @changes[attribute] = new_value
        instance_variable_set("@#{attribute}".to_sym, new_value)
      end
    end

    def save
      Huey::Request.put("lights/#{self.id}/state", body: MultiJson.dump(@changes))
      @changes = {}
      true
    end
    alias :commit :save

    def alert!
      Huey::Request.put("lights/#{self.id}/state", body: MultiJson.dump({alert: 'select'}))
    end

  end
end