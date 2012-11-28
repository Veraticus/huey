# Huey

Easy control of your Phillips Hue lights, in an attractive Gem format!

## Installation

Installing Huey is pretty simple. First include the Gem in your Gemfile:

```ruby
gem 'huey', git: 'git://github.com/Veraticus/Huey.git'
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
Huey::Errors::PressLinkButton: Press the link button and try your request again
```

Just like the message says, go press the link button on your Hue hub, and then reissue the request. It should work the second time. Then you can get to the exciting stuff:

```ruby
Huey::Bulb.all # Returns an array of your bulbs

bulb = Huey::Bulb.find(1) # Finds the bulb with the ID of 1
bulb = Huey::Bulb.find('Living Room') # Finds the bulb with the name 'Living Room'

bulb.alert! # Flashes the bulb in question once, useful for checking connectivity
bulb.on = false # Turn the bulb off
bulb.bri = 100 # Dim the bulb a little bit
bulb.ct = 500 # Change the bulb's color
```

Changes to the bulb take effect immediately. I think I'll be changing this soon so that they'll only take effect when saved.

## Quasi-Legal Mumbo-Jumbo

I am not affiliated with Phillips or the Phillips Hue in any way. I just think it's neat. While this Gem works for me, if it causes your lights to catastrophically fail it's not my fault. (Though I think the chances of this happening are pretty unlikely, you never know.)