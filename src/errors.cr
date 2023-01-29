# ===============================================================================
#         FILE:  errors.cr
#        USAGE:  Internal
#  DESCRIPTION:
#       AUTHOR:  Lewis E. Bogan
#      COMPANY:  Earthsea@Home
#      CREATED:  2023-01-30 12:07
#    COPYRIGHT:  (C) 2023 Lewis E. Bogan <lewis.bogan@comcast.net>
# Distributed under terms of the MIT license.
# ===============================================================================
module Errors
  class FileNotFoundError < Exception
    def self.error(path, colors = true)
      Colorize.enabled = colors
      abort <<-MISSING_FILE.colorize(:red)
    This config file, #{path}, doesn't exist!
    Try 'snob --help' for more information on generating it.
    MISSING_FILE
    end
  end

  class BadFileError < Exception
    def self.error(message, colors = true)
      Colorize.enabled = colors
      abort <<-BAD_FILE.colorize(:red)
    Error encountered: #{message}
    Try 'man snobrc.yml --help' for more config file information.
    BAD_FILE
    end
  end

  class InvalidHostnameError < Exception
    def self.error(message, colors = true)
      Colorize.enabled = colors
      abort <<-INVALID_HOSTNAME.colorize(:yellow)
    #{message}
    Check config file for correct remote host entry:
    - valid remote hostname
    - host actually exists
    - host has an entry in /etc/hosts or local dns resolver
    INVALID_HOSTNAME
    end
  end

  class BlankHostError < Exception
    def self.error(colors = true)
      Colorize.enabled = colors
      abort <<-BLANK_HOSTNAME.colorize(:yellow)
      Hostname can not be blank!
      BLANK_HOSTNAME
    end
  end

  class SnmpError < Exception
    def self.error(hostname : String, mib_oid : String, colors = true)
      Colorize.enabled = colors
      abort <<-SNMP_ERROR.colorize(:red)
      Error: cannot process this request because:
      1. net-snmp-utils not installed or
      2. host '#{hostname}' not snmpv3 enabled or
      3. incorrect credentials used or
      4. communication not permitted from this host or
      5. unknown object identifier: '#{mib_oid}'.
      Try 'snob --help' for more information.
      SNMP_ERROR
    end
  end

  class MissingOptionError < Exception
    def self.error(flag, colors = true)
      Colorize.enabled = colors
      abort <<-MISSING_OPTION.colorize(:red)
    Missing option argument: #{flag}
    Example: snob host #{flag} system
    MISSING_OPTION
    end
  end

  class InvalidOptionError < Exception
    def self.error(flag, colors = true)
      Colorize.enabled = colors
      abort <<-INVALID_OPTION.colorize(:red)
    Invalid option -- '#{flag}'
    Try 'snob --help' for more information.
    INVALID_OPTION
    end
  end
end
