# encoding: utf-8

module Huey

  # An actual object for a bulb.
  class Bulb
    ATTRIBUTES = [:on, :bri, :hue, :sat, :xy, :ct, :name, :transitiontime, :colormode, :effect, :reachable, :alert]
    attr_reader :id

    def self.all
      return @all if @all

      @all = Huey::Group.new
      Huey::Request.get['lights'].collect do |id, hash|
        @all.bulbs << Bulb.new(id, hash)
      end
      @all
    end

    def self.find(id)
      self.all.find {|b| b.id == id || b.name.include?(id.to_s)}
    end

    def self.find_all(id)
      group = Huey::Group.new
      self.all.select {|b| b.id == id || b.name.include?(id.to_s)}.each {|b| group.bulbs << b}
      group
    end

    def initialize(id, hash)
      @id = id.to_i
      @changes = {}
      @name = hash['name']

      reload(hash)
    end

    def reload(hash = nil)
      hash ||= Huey::Request.get("lights/#{self.id}")

      (Huey::Bulb::ATTRIBUTES - [:name]).each do |attribute|
        instance_variable_set("@#{attribute}".to_sym, hash['state'][attribute.to_s])
      end

      self
    end

    Huey::Bulb::ATTRIBUTES.each do |attribute|
      define_method(attribute) do
        instance_variable_get("@#{attribute}".to_sym)
      end

      define_method("#{attribute}=".to_sym) do |new_value|
        return new_value if self.send(attribute) == new_value

        @changes[attribute] = new_value
        instance_variable_set("@#{attribute}".to_sym, new_value)
      end unless [:colormode, :reachable].include?(attribute)
    end

    def save
      Huey::Request.put("lights/#{self.id}/state", body: MultiJson.dump(@changes))
      @changes = {}
      true
    end
    alias :commit :save

    def update(hash)
      hash.each { |k, v| self.send("#{k}=".to_sym, v) }

      save
    end

    def rgb
      Color::HSL.new(self.hue.to_f / 182.04, self.sat.to_f / 255.0 * 100.0, self.bri.to_f / 255.0 * 100.0).to_rgb.html
    end

    def rgb=(hex)
      color = Color::RGB.from_html(hex)

      # Manual calcuation is necessary here because of an error in the Color library
      r = color.r
      g = color.g
      b = color.b
      max = [r, g, b].max
      min = [r, g, b].min
      delta = max - min
      v = max * 100

      if (max != 0.0)
        s = delta / max * 100
      else
        s = 0.0
      end

      if (s == 0.0)
        h = 0.0
      else
        if (r == max)
          h = (g - b) / delta
        elsif (g == max)
          h = 2 + (b - r) / delta
        elsif (b == max)
          h = 4 + (r - g) / delta
        end

        h *= 60.0

        if (h < 0)
          h += 360.0
        end
      end

      self.hue = (h * 182.04).round
      self.sat = (s / 100.0 * 255.0).round
      self.bri = (v / 100.0 * 255.0).round
    end

    def alert!
      self.update(alert: 'none') if self.alert != 'none'
      self.update(alert: 'select')
    end

  end
end
