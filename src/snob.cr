#===============================================================================
#
#         FILE:  snob.cr
#        USAGE:  snob.cr [hostname] [oid]
#  DEVELOPMENT:  crystal build src/snob.cr
#  DESCRIPTION:  Snmp Network Object Browser.
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#
#         BUGS:  ---
#        NOTES:  #
#       AUTHOR:  Lewis E. Bogan
#      COMPANY:  Earthsea@Home
#      CREATED:  2017-11-08 14:30
#    COPYRIGHT:  (C) 2017 Lewis E. Bogan <lewis.bogan@comcast.net>
#     GIT REPO:  ssh://devforge/var/lib/git/snob.git
#             :  git remote add origin ssh://devforge/var/lib/git/snob.git
#             :  git push -u origin master
# Distributed under terms of the MIT license.
#===============================================================================
require "./snob/*"
require "yaml"


# Allows displaying object methods during development.
class Object
  macro methods
    {{ @type.methods.map &.name.stringify }}
  end
end

# This class is the main application. It checks for command line arguments, 
# valid hostname, and snmpv3 credentials.
#
# We have to rely on having net-snmp installed on our pc. 
# TODO: Bind the net-snmp c library to make this app portable.
class App
  include Reports
  include Utils
  include Snmp

  # Runs the main application.
  def run
    puts

    # Asks for a command line argument if none is given on the command line.
    if ARGV.empty?
      print("Enter hostname: ")
      hostname = gets.to_s
    else
      hostname = ARGV[0]
    end

    # Checks if host exists on this network
    args = ("-c 2 #{hostname}").split(" ") # => Array of String
    say_hey(hostname)
    status, result = run_cmd("ping", args)
    abort "ping: #{hostname}: is unreachable on this network" unless status == 0

    # Loads the hidden system file in the user's home directory.
    config_file = File.expand_path("~/.snobrc.yml")

    # Checks for the existance of a valid config file and tests if host
    #   is in it. Otherwise, asks for manual entry of credentials.
    if File.exists?(config_file) && fetch_config(config_file)["#{hostname}"]? != nil
      config = fetch_config(config_file)["#{hostname}"] # => YAML::Any
    else
      config = configure_session[0].to_h # => Hash(String, String)
    end

    # Creates a Snmp object.
    host = Snmp.new(config["auth"].to_s,
      config["priv"].to_s,
      config["user"].to_s,
      config["crypto"].to_s.upcase) # => Snmp

    # Invokes the walk_mib3 method on the Snmp object, host, and
    #   gets status => Int32 and results => String
    mib_oid = ARGV.size > 1 ? ARGV[1] : "system"
    status, results = host.walk_mib3(hostname, mib_oid)
    abort "not snmpv3 enabled or unknown object identifier: #{mib_oid}." unless status == 0

    # Show your stuff
    table = {} of String => String # => Hash(String, String)
    formatted_results = results.split("\n") # => Array(String)
    format_table(formatted_results, table)
    display_table(table, hostname, mib_oid)
  end
end

App.new.run
