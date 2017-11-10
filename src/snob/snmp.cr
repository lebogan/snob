require "./utils.cr"

# Defines the Snmp object and forms the **walk_mib3** command string.
module Snmp
  class Snmp
    include Utils
    property :auth, :priv, :user, :crypto

    # Creates a new Snmp object.
    #     Snmp.new(args...) # => Snmp
    def initialize(auth : String, priv : String, user : String, crypto : String)
      @auth = auth
      @priv = priv
      @user = user
      @crypto = crypto
    end

    # Walks the mib tree.
    def walk_mib3(hostname, oid)
      cmd = "snmpwalk"
      args = ("-v3 -u #{@user} -OQu -l authpriv -a MD5 -A #{@auth} -x #{@crypto} -X #{@priv} #{hostname} #{oid}").split(" ")
      run_cmd(cmd, args)
    end
  end
end

