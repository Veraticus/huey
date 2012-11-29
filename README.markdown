# Huey

Easy control of your Phillips Hue lights, in an attractive Gem format!

## Installation

Installing Huey is pretty simple. First include the Gem in your Gemfile:

```ruby
gem 'huey', git: 'git://github.com/Veraticus/huey.git'
```

(It's not in RubyGems yet because I'm not totally sure it's actually stable enough for release.)

You shouldn't need to initialize anything to make Huey work correctly, but if you want to specify some configuration options go nuts:

```ruby
Huey.configure do |config|
  # For discovering the Hue hub, usually you won't have to change this
  config.ssdp_ip = '239.255.255.250' 

  # Also for discovering the Hue hub
  config.ssdp_port = 1900            

  # If you get constant errors about not being able to find the Hue hub and you're sure it's connected, increase this
  config.ssdp_ttl = 1

  # Change this if you don't like the included uuid
  config.uuid = '0123456789abdcef0123456789abcdef'
end
```

## Usage

The first time you issue any Huey command, you're likely to see something like this:

```ruby
Huey::Errors::PressLinkButton: 'Press the link button and try your request again'
```

Just like the message says, go press the link button on your Hue hub, and then reissue the request. It should work the second time. Then you can get to the exciting stuff:

```ruby
Huey::Bulb.all # Returns an array of your bulbs

bulb = Huey::Bulb.find(1) # Finds the bulb with the ID of 1
bulb = Huey::Bulb.find('Living Room') # Finds the bulb with the name 'Living Room'

bulb.alert! # Flashes the bulb in question once and immediately, useful for checking connectivity

bulb.bri = 100 # Let's dim the bulb a little bit
bulb.ct = 500 # And make it a little more orange

bulb.save # Apply all the changes you've made

bulb.update(bri: 100, ct: 500) # Set and save in one step
```

Changes to the bulb only take effect when you call `save` on it. If you prefer, `save` is aliased as `commit`.

For your reference, the attributes on bulb you can change are:
- **name**: Any string. The bulb's name.
- **on**: `true` or `false`. Set and commit to activate or deactive the bulb.
- **bri**: The bulb's brightness, between `0` and `254`. 0 is not off!
- **hue**: For hue/saturation mode. Between `0` and `65535`. Multiply the hue degree by 182 to get this.
- **sat**: For hue/saturation mode. Between `0` and `254`.
- **xy**: For CIE 1931 mode. An array of two floats, like: [0.44, 0.4051]
- **ct**: For color temperature mode. Expressed in [mireds](http://en.wikipedia.org/wiki/Mired), an integer between `154` and `500`.
- **transitiontime**: An integer. Tenths of a second, so `10` is 1 second, and `100` is 10 seconds. Use `0` for instantaneous transitions. 

I used [http://rsmck.co.uk/hue](http://rsmck.co.uk/hue) as the source for all this stuff.

## Quasi-Legal Mumbo-Jumbo

I am not affiliated with Phillips or the Phillips Hue in any way. I just think it's neat. While this Gem works for me, if it causes your lights to catastrophically fail it's not my fault. (Though I think the chances of this happening are pretty unlikely, you never know.)