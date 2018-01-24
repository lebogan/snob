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

require "./utils.cr"

# Defines the Snmp object and forms the **walk_mib3** command string.
module Snmp
  struct Snmp
    include Utils
    property :auth, :priv, :user, :crypto

    # Creates a new Snmp object.
    #
    # ```
    # Snmp.new(args...) # => Snmp
    # ```
    #
    def initialize(auth : String, priv : String, user : String, crypto : String)
      @auth = auth
      @priv = priv
      @user = user
      @crypto = crypto
    end

    # Walks the mib tree.
    def walk_mib3(hostname : String, oid : String) : Tuple(Int32, String)
      run_cmd("snmpwalk", {"-v3", "-u", "#{@user}", "-OQUsT", "-l", "authpriv",
                           "-a", "MD5", "-A", "#{@auth}", "-x", "#{@crypto}", "-X",
                           "#{@priv}", "#{hostname}", "#{oid}"}
      )
    end
  end
end
