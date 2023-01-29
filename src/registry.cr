# ===============================================================================
#         FILE:  registry.cr
#        USAGE:  Internal
#  DESCRIPTION:
#       AUTHOR:  Lewis E. Bogan
#      COMPANY:  Earthsea@Home
#      CREATED:  2023-01-26 15:35
#    COPYRIGHT:  (C) 2023 Lewis E. Bogan <lewis.bogan@comcast.net>
# Distributed under terms of the MIT license.
# ===============================================================================

# Thanks George Dietrich - @Blacksmoke16
# Make your Config class more like a Registry of Host configurations.
# Make a singleton instance of it, and expose a method _get_ to allow getting the configuration
# for a specific host.
# Registry.get hostname # => Registry::V3Credentials
#
class Registry
  record V3Credentials, user : String, auth_pass : String, priv_pass : String, auth : String, priv : String do
    include YAML::Serializable
  end

  private class_getter instance : self { new } # is this self.instance => @@instance ||= new?

  def self.get(hostname : String) : V3Credentials
    self.instance.configurations[hostname]
  end

  protected getter configurations : Hash(String, V3Credentials)

  # initiated by class_getter _instance_?
  private def initialize
    @configurations = Hash(String, V3Credentials).from_yaml File.read(CONFIG_FILE)
  end
end
