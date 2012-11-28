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

      Bulb::Attributes.each do |name|
        instance_variable_set("@#{name}".to_sym, hash[name.to_s])
      end
    end

    Attributes.each do |name|
      define_method(name) do
        instance_variable_get("@#{name}".to_sym)
      end

      define_method("#{name}=".to_sym) do |new_value|
        return true if self.send(name) == new_value

        instance_variable_set("@#{name}".to_sym, new_value)
        Huey::Request.put("lights/#{self.id}/state", body: MultiJson.dump({name => new_value}))
      end
    end

    def alert!
      Huey::Request.put("lights/#{self.id}/state", body: MultiJson.dump({alert: 'select'}))
    end

  end
end