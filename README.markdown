# Huey

Easy control of your Philips Hue lights, in an attractive Gem format!

## Installation

### From the Terminal

You probably want to start experimenting through IRB. Install the gem from your terminal:

```
$ gem install huey
```

### In an Application

Add Huey to your `Gemfile`:

```ruby
gem 'huey'
```

Then run `bundleinstall` from your terminal.

## Usage

### Getting Started

Your Hue bridge maintains a "whitelist" of known users who are allowed to access the API. Huey by default uses `'0123456789abdcef0123456789abcdef'` as the indentifier for any application using the gem. *Want a more unique/secure username? Check out the Configuration section below.*

#### Manual user registration
Open up an IRB session:

```irb
$ irb
2.1.0 :001 > require 'huey'
 => true
 2.1.0 :002 > Huey::Request.register
Huey::Errors::PressLinkButton: Press the link button and try your request again
```

That's expected the first time Huey is used with your bridge. Go press the big white link button on the bridge then retry the `register` call **within 30 seconds**:

```irb
2.1.0 :003 > Huey::Request.register
 => [{"success"=>{"username"=>"0123456789abdcef0123456789abcdef"}}]
```
Now you're ready to go! Since the username is stored in the bridge, you won't have to do this again.

#### Automatic user registration

The first time you issue a request towards the Hue bridge and the bridge never communicated before with your application (i.e. the Hue bridge doesn't recognise the user Huey supplied), Huey will automatically call `Huey::Request.register`. As an effect this will then successfully raise: `Huey::Errors::PressLinkButton`. Manually calling `Huey::Request.register` may thus be omitted when it doesn't fit your application.


### Bulbs

```ruby
bulb = Huey::Bulb.find(1)             # Finds the bulb with the ID of 1
bulb = Huey::Bulb.find('Living Room') # Finds the bulb with the name 'Living Room'

bulb.alert! # Flashes the bulb in question once and immediately, useful
            # for checking connectivity

bulb.bri = 100 # Let's dim the bulb a little bit
bulb.ct = 500  # And make it a little more orange
bulb.save      # Apply all the changes you've made

bulb.update(bri: 100, ct: 500) # Set and save in one step

bulb.rgb = '#8FF1F5' # Everyone loves aqua
bulb.commit          # Alias for save

bulb.reload # Refresh changes to the bulb, made perhaps with another app

Huey::Bulb.all                            # Returns a group of all bulbs
Huey::Bulb.all.alert!                     # Makes all your bulbs start flashing
Huey::Bulb.all.update(bri: 255, on: true) # Turn on all your bulbs and increase
                                          # brightness to max
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

Returned arrays of bulbs are grouped into a convenience class called `Huey::Group`. It acts like an array, but any huey-specific method you pass in will be invoked on all the bulbs.

You can also simply and sensibly create groups of bulbs yourself if you like.

```ruby
Huey::Group.new('Living Room') # Contains all bulbs that have 'Living Room' in their name
Huey::Group.new('Living Room', 'Foyer') # All bulbs that have either 'Living Room' or 'Foyer' in their name
g = Huey::Group.new(Huey::Bulb.find(1), Huey::Bulb.find(3)) # A group specifically containing bulbs 1 and 3
g.name = 'My Bulbs' # Name your group to find it later
g.save # Pushes your new group to the Hue hub

group.bri = 200
group.on = true
group.save # Updates any changes to the group and commits all changes to the bulbs in it

group.update(bri: 200, ct: 500) # Set and save in one step
```

`Group#save` will only create a group on the Hue hub if the group has a name and bulbs. If you're using a group as a temporary collection of bulbs and don't want to persist it, just don't name it: it won't be saved to the hub unless you give it a name.

### Events

You probably want to always do the same actions over and over again to a group of bulbs. To help encapsulate that idea, we have events.

```ruby
all = Huey::Group.new(Huey::Bulb.all)
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

## Configuration Details

You shouldn't need to initialize anything to make Huey work correctly, but you can define several configuration options:

```ruby
Huey.configure do |config|
  # Huey now uses the Philips Hue API to discover local bridges, but you can
  # specify the Hue IP manually if your Huey server is not on your
  # local network.
  config.hue_ip = '123.456.789.012'

  # SSDP is disabled by default. Do not enable it unless you have a compelling
  # reason to do so.
  config.ssdp = true

  # Specify the SSDP IP. Do not use this unless you're using SSDP broadcasting
  # at a non-standard IP.
  config.ssdp_ip = '239.255.255.250'

  # As per the above, but for a non-standard port.
  config.ssdp_port = 1900

  # If your SSDP connections keep timing out, increase this.
  config.ssdp_ttl = 1

  # Change this if you don't like the included uuid.
  config.uuid = '0123456789abdcef0123456789abcdef'
end
```

## Attribution

The structure of the configuration files and the modules are taken from [Mongoid](https://github.com/mongoid/mongoid), which had some really great ideas.

The SSDP discovery driver is lifted whole cloth from turboladen's [UPNP](https://github.com/turboladen/upnp). I would have used it as a Gem dependency, but unfortunately, it's not released as a Gem, so I just took it. The code is his, though, not mine.

## Quasi-Legal Mumbo-Jumbo

I am not affiliated with Philips or the Philips Hue in any way. I just think it's neat. While this Gem works for me, if it causes your lights to catastrophically fail it's not my fault. (Though I think the chances of this happening are pretty unlikely, you never know.)

## Contributors

Many thanks to the following diligent contributors, without whom this project would not be nearly as awesome:

* [sankage](https://github.com/sankage)
* [raspygold](https://github.com/raspygold)
* [larskrantz](https://github.com/larskrantz)

## Copyright

Copyright (c) 2012 Josh Symonds.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
