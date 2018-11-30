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
  struct Snmp
    property :auth, :priv, :user, :crypto

    # Creates a new Snmp object for a walk session.
    #
    # ```
    # Snmp.new(args...) # => Snmp
    # ```
    #
    def initialize(@auth : String, @priv : String, @user : String, @crypto : String)
    end

    # Walks the mib tree branch.
    #
    # ```
    # Snmp.walk_mib3("myhost", "system", "vQ") # => Tuple(Int32, String)
    # ```
    #
    def walk_mib3(hostname : String, oid : String, format : String) : Tuple(Int32, String)
      Myutils.run_cmd("snmpwalk", {"-v3", "-u", "#{@user}", "-O#{format}", "-l", "authpriv",
                                   "-a", "MD5", "-A", "#{@auth}", "-x", "#{@crypto}", "-X",
                                   "#{@priv}", "#{hostname}", "#{oid}"}
      )
    end
  end
end
