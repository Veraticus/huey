module Huey

  class Bridge

    ATTRIBUTES = [
      :name,
      :mac,
      :dhcp,
      :ipaddress,
      :netmask,
      :gateway,
      :proxyaddress,
      :proxyport,
      :UTC,
      :whitelist,
      :swversion,
      :swupdate,
      :linkbutton,
      :portalservices
    ]

    # set instance (read) methods for ALL bridge attributes
    ATTRIBUTES.each do |a|
      attr_reader a
    end

    # set instance (write) methods for ONLY :name and :linkbutton attributes
    # this is to prevent accidental bridge-nuking; TODO maybe add more later
    attr_writer :name, :linkbutton

    # a new instance of Huey::Bridge will assign existing values to instance variables
    def initialize
      config_hash = Huey::Request.get('config')
      Huey::Bridge::ATTRIBUTES.each do |attribute|
        instance_variable_set("@#{attribute}", config_hash[attribute.to_s])
      end
    end

    # reloads attributes from the bridge, and reassigns instance variables
    # remember that the bridge resets :linkbutton to false after 30 seconds
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

  end

end
