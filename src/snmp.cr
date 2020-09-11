# ===============================================================================
#         FILE:  snmp.cr
#        USAGE:  Internal
#  DESCRIPTION:  Snmp stuff.
#       AUTHOR:  Lewis E. Bogan
#      COMPANY:  Earthsea@Home
#      CREATED:  2017-12-17 15:26
#    COPYRIGHT:  (C) 2017 Lewis E. Bogan <lewis.bogan@comcast.net>
# Distributed under terms of the MIT license.
# ===============================================================================

# Defines the Snmp object and forms the **walk_mib3** command string.
module Snmp
  class Snmp
    property :user, :auth_pass, :priv_pass, :auth, :crypto

    # Creates a new Snmp object for a walk session.
    #
    # ```
    # Snmp.new(args...) # => Snmp
    # ```
    #
    def initialize(@user : String, @auth_pass : String, @priv_pass : String,
                   @auth : String, @crypto : String)
    end

    # Walks the mib tree branch.
    #
    # ```
    # Snmp.walk_mib3("myhost", "system", "vQ") # => Tuple(Int32, String)
    # ```
    #
    def walk_mib3(hostname : String, oid : String, format : String) : Tuple(Int32, String)
      Util.run_cmd("snmpwalk", {"-v3", "-u", "#{@user}", "-O#{format}", "-l", "authpriv",
                                "-a", "#{auth}", "-A", "#{@auth_pass}", "-x", "#{@crypto}", "-X",
                                "#{@priv_pass}", "#{hostname}", "#{oid}"}
      )
    end
  end
end
