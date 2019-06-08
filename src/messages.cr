# ===============================================================================
#         FILE:  messages.cr
#        USAGE:  Internal
#  DESCRIPTION:  Contains error messages.
#       AUTHOR:  Lewis E. Bogan
#      COMPANY:  Earthsea@Home
#      CREATED:  2017-12-24 10:40
#    COPYRIGHT:  (C) 2017 Lewis E. Bogan <lewis.bogan@comcast.net>
# Distributed under terms of the MIT license.
# ===============================================================================

# Error and other messages.
module Messages
  extend self

  def banner_message
    <<-BANNER
    Usage: snob [OPTIONS] [HOST]
    Browse a host's snmpv3 mib tree.

    Prompts for HOST if not specified on the command-line. Also, prompts
    for security credentials if HOST is not in the config file, snobrc.yml.

    BANNER
  end

  def copyright_message
    <<-COPYRIGHT

  Copyright (c) 2019 - #{Time.local.to_s("%Y")} Lewis E. Bogan
  The MIT License (MIT); http://opensource.org/licences/MIT
  creater, maintainer: lebogan <lewis.bogan@comcast.net>
  COPYRIGHT
  end

  def ping_message(hostname : String)
    <<-PING
    ping: #{hostname} is unreachable on this network
    PING
  end

  def blank_host_message
    <<-HOSTNAME
    snob: hostname can not be blank
    HOSTNAME
  end

  def snmp_message(hostname : String, mib_oid : String)
    <<-SNMP
    Error: cannot process this request because:
    1. net-snmp-utils not installed or
    2. host '#{hostname}' not snmpv3 enabled or
    3. incorrect credentials used or
    4. communication not permitted from this host or
    5. unknown object identifier: '#{mib_oid}'.
    Try 'snob --help' for more information.
    SNMP
  end

  def missing_message(flag : String)
    <<-MISSING_OPTION
    Missing option argument: #{flag} OID
    Example: snob -m lldp hostname
    MISSING_OPTION
  end

  def invalid_message(flag : String)
    <<-INVALID_OPTION
    snob: invalid option -- '#{flag}'
    Try 'snob --help' for more information.
    INVALID_OPTION
  end
end
