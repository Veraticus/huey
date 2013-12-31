# encoding: utf-8

module Huey

  # A group is a collection of bulbs.
  class Group
    include Enumerable
    attr_reader :id
    attr_accessor :bulbs, :name

    def self.all
      @all ||= reload
    end

    def self.reload
      @all = [].tap do |all|
        Huey::Request.get['groups'].collect do |id, hash|
          next if id == '0' # Group 0 is a special group of all bulbs
          hash['id'] = id
          all << Huey::Group.new(hash)
        end
      end
    end

    def self.find(id)
      self.all.find {|g| g.id == id || (g.name && g.name == id.to_s)}
    end

    def initialize(*input)
      @bulbs = []
      @attributes_to_write = {}

      input = input.first if input.first.is_a?(Array) || input.first.is_a?(Hash)
      if input.first.is_a?(Bulb) # Then this group was initialized with only a single bulb
        @bulbs = input
      elsif input.is_a?(Array) # Then this group was initialized with an array of bulb IDs
        @bulbs = input.collect {|s| Huey::Bulb.find_all(s)}.flatten.uniq
      elsif input.is_a?(Hash) # Then this group was initialized with an API response
        @bulbs = input['lights'].collect {|id| Huey::Bulb.find(id.to_i)}.flatten.uniq
        @id = input['id'].to_i
        @name = input['name']
      end

      self
    end

    Huey::Bulb::ATTRIBUTES.each do |attribute|
      define_method("#{attribute}=".to_sym) do |new_value|
        @attributes_to_write[attribute] = new_value
      end unless [:name, :colormode, :reachable].include?(attribute)
    end

    def save
      update_bulbs
      write_attributes
      self
    end
    alias :commit :save

    def destroy
      return true if new_record?
      Huey::Request.delete("groups/#{self.id}")
      true
    end

    def update_bulbs
      response = self.collect {|b| b.update(@attributes_to_write)}
      @attributes_to_write = {}
      response
    end

    def write_attributes
      return true unless self.name && !self.bulbs.empty?

      attributes = MultiJson.dump({name: @name, lights: @bulbs.collect {|b| b.id.to_s}})

      if self.new_record?
        response = Huey::Request.post("groups", body: attributes)
        @id = response.first['success']['id'].match(/\/groups\/([0-9]*)/)[1].to_i
      else
        Huey::Request.put("groups/#{self.id}", body: attributes)
      end
    end

    def new_record?
      @id.nil?
    end

    def update(attrs)
      self.collect {|b| b.update(attrs)}
    end

    def each(&block)
      bulbs.each {|b| block.call(b)}
    end

    def method_missing(meth, *args, &block)
      if !self.bulbs.empty? && self.bulbs.first.respond_to?(meth)
        h = {}
        self.each {|b| h[b.id] = b.send(meth, *args, &block)}
        h
      elsif self.bulbs.respond_to?(meth)
        bulbs.send(meth, *args, &block)
      else
        super
      end
    end
  end

end