# Huey

Easy control of your Phillips Hue lights, in an attractive Gem format!

## Installation

Installing Huey is pretty simple. First include the Gem in your Gemfile:

```ruby
gem 'huey'
```

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

Just like the message says, go press the link button on your Hue hub, and then reissue the request. It should work the second time. Then you can get to the exciting stuff.

### Bulbs

```ruby
Huey::Bulb.all # Returns an array of your bulbs

bulb = Huey::Bulb.find(1) # Finds the bulb with the ID of 1
bulb = Huey::Bulb.find('Living Room') # Finds the bulb with the name 'Living Room'

bulb.alert! # Flashes the bulb in question once and immediately, useful for checking connectivity

bulb.bri = 100 # Let's dim the bulb a little bit
bulb.ct = 500 # And make it a little more orange

bulb.save # Apply all the changes you've made

bulb.update(bri: 100, ct: 500) # Set and save in one step

bulb.rgb = '#8FF1F5' # Everyone loves aqua

bulb.commit # Alias for save
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

I've added in some convenience attributes as well:

- **rgb**: An HTML hex value. Will automatically convert to hue/saturation.

### Groups

You can also simply and sensibly create groups of bulbs.

```ruby
Huey::Group.new('Living Room') # Contains all bulbs that have 'Living Room' in their name
Huey::Group.new('Living Room', 'Foyer') # All bulbs that have either 'Living Room' or 'Foyer' in their name
g = Huey::Group.new(Huey::Bulb.find(1), Huey::Bulb.find(3)) # A group specifically containing bulbs 1 and 3
g.name = 'My Bulbs' # Name your group to find it later

Huey::Group.import('groups.yml') # Import many groups at once from a YAML file.
# The file should look like this:
#
# living_room: [TV, Living Room - Fireplace]
# foyer: [Foyer]
# bedroom: [Bedroom]

group = Huey::Group.find('My Bulbs')

group.bri = 200
group.on = true
group.save # All changes you've made are committed to all the bulbs in a group

group.update(bri: 200, ct: 500) # Set and save in one step
```

### Events

You probably want to always do the same actions over and over again to a group of bulbs. To help encapsulate that idea, we have events.

```ruby
all = Huey::Group.new(bulbs: Huey::Bulb.all)
event = Huey::Event.new(name: 'All Lights Off', group: all, actions: {on: false})

event.execute # All lights turn off
```

If you like, you can schedule an event to execute only at a particular time if you have a really gimpy scheduling system.

```ruby
event = Huey::Event.new(name: 'All Lights Off', group: all, actions: {on: false}, at: '9PM')

event.execute # nothing happens unless it's 9PM
Huey::Event.execute # run all events that should be run this second
```

It's probably easier for you to just directly invoke events from your scheduling system (cron or the like). To aid with that you can load events from a YAML file:

```ruby
Huey::Group.import('groups.yml') # So that we can find groups
Huey::Event.import('events.yml')
# The file should look like this:
# Wakeup Call:
#   group: Bedroom
#   at: 9AM
#   actions:
#     bri: 100
#     "on": true # Note the quotes, `on` is a reserved word for Yaml parsers
#
# Goodnight Time:
#   group: Living Room
#   at: 12AM
#   actions:
#     bri: 10
#     "on": false # Note the quotes, `on` is a reserved word for Yaml parsers

Huey::Event.find('Wakeup Call').execute
```

## Attribution

The structure of the configuration files and the modules are taken from [Mongoid](https://github.com/mongoid/mongoid), which had some really great ideas.

The SSDP discovery driver is lifted whole cloth from turboladen's [UPNP](https://github.com/turboladen/upnp). I would have used it as a Gem dependency, but unfortunately, it's not released as a Gem, so I just took it. The code is his, though, not mine.

## Quasi-Legal Mumbo-Jumbo

I am not affiliated with Phillips or the Phillips Hue in any way. I just think it's neat. While this Gem works for me, if it causes your lights to catastrophically fail it's not my fault. (Though I think the chances of this happening are pretty unlikely, you never know.)

## Contributors

Many thanks to the following diligent contributors, without whom this project would not be nearly as awesome:

* [sankage](https://github.com/sankage)

## Copyright

Copyright (c) 2012 Josh Symonds.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.