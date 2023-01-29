# ===============================================================================
#         FILE:  messages.cr
#        USAGE:  Internal
#  DESCRIPTION:  Contains error messages.
#       AUTHOR:  Lewis E. Bogan
#      COMPANY:  Earthsea@Home
#      CREATED:  2017-12-24 10:40
#    COPYRIGHT:  (C) 2021 Lewis E. Bogan <lewis.bogan@comcast.net>
# Distributed under terms of the MIT license.
# ===============================================================================

# Error and other messages.
module Messages
  extend self

  def self.print_version
    puts <<-DESCRIPTION
    snob v#{VERSION} [compiled with Crystal #{Crystal::VERSION}] (#{Util.date})

    Copyright (c) 2019 - #{Time.local.to_s("%Y")} Lewis E. Bogan
    The MIT License (MIT); http://opensource.org/licences/MIT
    creater, maintainer: lebogan <lewis.bogan@comcast.net>
    DESCRIPTION
    exit 0
  end

  def self.print_banner
    <<-BANNER
    Usage: snob [OPTIONS] [HOST]
    Browse a host's snmpv3 mib tree.

    Prompts for HOST if not specified on the command-line. Also, prompts
    for security credentials if HOST is not in the config file, snobrc.yml.

    Options:
    BANNER
  end

  def self.print_usage
    puts <<-USAGE
    Usage: snob [OPTIONS] [HOST]
    See snob --help or man page for more information.
    USAGE
    exit 0
  end

  def self.print_help(parser)
    puts parser
    exit 0
  end

  def self.print_default_config_message(config_file)
    puts <<-CONFIG
  A default configuration file, #{config_file} has been created to hold
  a registry of host credentials.

  You will be prompted to enter host credentials if they are missing from
  this registry.

  It can also be edited using the '--edit' option to change any values.

  CONFIG
  end
end
