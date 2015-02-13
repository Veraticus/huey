module Huey

  class Bridge

    # all available attributes from the bridge config; from the latest official
    # hue api v1.4 documentation at:
    # http://www.developers.meethue.com/documentation/configuration-api
    ATTRIBUTES = [
      :apiversion,
      :dhcp,
      :gateway,
      :ipaddress,
      :linkbutton,
      :localtime,
      :mac,
      :name,
      :netmask,
      :portalservices,
      :proxyaddress,
      :proxyport,
      :swupdate,
      :swversion,
      :timezone,
      :UTC,
      :whitelist,
      :zigbeechannel
    ]

    # set instance (read) methods for ALL bridge attributes
    ATTRIBUTES.each do |a|
      attr_reader a
    end

    # set instance (write) methods for ONLY :name and :linkbutton attributes;
    # this is to prevent accidental bridge-nuking
    attr_writer :name, :linkbutton

    # a new instance of Huey::Bridge assigns values to instance variables
    def initialize
      config_hash = Huey::Request.get('config')
      Huey::Bridge::ATTRIBUTES.each do |attribute|
        instance_variable_set("@#{attribute}", config_hash[attribute.to_s])
      end
    end

    # reloads attributes from the bridge, and reassigns instance variables
    def reload
      config_hash = Huey::Request.get('config')
      Huey::Bridge::ATTRIBUTES.each do |attribute|
        instance_variable_set("@#{attribute}", config_hash[attribute.to_s])
      end
      self
    end

    # save changes back to the bridge, and reload attributes
    def save
      attributes = MultiJson.dump({ name: @name, linkbutton: @linkbutton })
      Huey::Request.put("config", body: attributes)
      self.reload
    end

    # deauthorize a whitelisted user/application
    def deauth(username)
      Huey::Request.delete("config/whitelist/#{username}")
      self.reload
    end

    # set and save linkbutton state in one step; it resets in 30 seconds!
    def link!
      self.linkbutton = true
      self.save
      self.linkbutton
    end

    # reload and check linkbutton state in one step; be careful not to overuse,
    # since it is querying the bridge api every time
    def linking?
      self.reload
      self.linkbutton
    end

  end

end
