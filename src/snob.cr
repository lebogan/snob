# ===============================================================================
#         FILE:  snob.cr
#        USAGE:  snob [arguments...]
#  DEVELOPMENT:  crystal build|run src/snob.cr
#      RELEASE:  crystal build --release --no-debug src/snob.cr
#  DESCRIPTION:  A simple Snmp Network Object Browser.
#      OPTIONS:  ---
# REQUIREMENTS:  net-snmp net-snmp-utils
#         BUGS:  ---
#        NOTES:  #
#       AUTHOR:  Lewis E. Bogan
#      COMPANY:  Earthsea@Home
#      CREATED:  2017-11-10 10:19
#    COPYRIGHT:  (C) 2017 Lewis E. Bogan <lewis.bogan@comcast.net>
#     GIT REPO:  ssh://devforge/var/lib/git/snob.git
#             :  git remote add origin ssh://devforge/var/lib/git/snob.git
#             :  git push -u origin master
# Distributed under terms of the MIT license.
# ===============================================================================
require "./snob/*"
require "yaml"
require "option_parser"

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
# TODO: Make utility default to "system" when --mib flag is mossing.
# TODO: Test, test, test!
class App
  include Reports
  include Utils
  include Snmp
  include Config
  include Session

  OIDLIST = {arp:    "ipNetToPhysicalPhysAddress",
             lldp:   "1.0.8802.1.1.2.1.4.1.1.9",
             sys: "system",
             mem:    "memory",
             dsk:    "dskTable",
             ifdesc:    "ifDescr",
  }

  # Runs the main application.
  def run
    mib_oid = ""
    display_raw = false
    file_write = false

    OptionParser.parse! do |parser|
      parser.banner = <<-BANNER
      Usage: snob [OPTIONS] [HOST]
      Browse a host's snmpv3 mib tree.

      Prompts for HOST if not specified on the command-line. Also, prompts
      for security credentials if HOST is not in the config file, ~/.snobrc.yml.

      BANNER
      parser.on("-l", "--list", "List some pre-cooked OIDs") do
        list_oids(OIDLIST)
        exit 0
      end
      parser.on("-m OID", "--mib=OID", "Show information for this oid") do |oid|
        if OIDLIST.has_key?(oid)
          mib_oid = OIDLIST["#{oid}"]
        elsif !oid.blank?
          mib_oid = oid
        else
          mib_oid = "system"
        end
      end
      parser.on("-d", "--dump", "Write output to file") { file_write = true }
      parser.on("-r", "--raw", "Show raw mib information for this oid") { display_raw = true }
      parser.on("-h", "--help", "Show this help") do
        puts parser
        exit 1
      end
      parser.on("-v", "--version", "Show version") do
        puts "snob v#{Snob::VERSION}"
        exit 1
      end
    end

    # Asks for a command line argument if none is given on the command line.
    if ARGV.empty?
      print("Enter hostname: ")
      hostname = gets.to_s
    else
      hostname = ARGV[0]
    end

    # Checks if host exists on this network
    args = ("-c 2 #{hostname}").split(" ") # => Array of String
    status, result = run_cmd("ping", args)
    abort "ping: #{hostname}: is unreachable on this network" unless status == 0

    config_file = File.expand_path("~/.snobrc.yml")

    # Checks for existance of a config file and creates a dummy entry
    #    if the user answers yes.
    check_for_config(config_file)

    # Checks for the existance of a valid config file and tests if host
    #   is in it. Otherwise, asks for manual entry of credentials and
    #   adds them to existing config file.
    if File.exists?(config_file) && fetch_config(config_file)["#{hostname}"]? != nil
      config = fetch_config(config_file)["#{hostname}"] # => YAML::Any
    else
      puts "#{hostname} is not in config file. Configuring..."
      config = configure_session[0].to_h # => Hash(String, String)
      options = {hostname => config}
      session = options.to_yaml.gsub("---", "")
      puts "You entered: %s" % session
      choice = ask("Save this session? ")
      add_session(config_file, session) if /#{choice}/i =~ "yes"
    end

    # Creates a Snmp object and invokes the walk_mib3 method on the Snmp object, host.
    #     Returns # => Tuple{Int32, String}
    host = Snmp.new(
      config["auth"].to_s,
      config["priv"].to_s,
      config["user"].to_s,
      config["crypto"].to_s.upcase) # => Snmp
    status, results = host.walk_mib3(hostname, mib_oid)
    snmp_message = <<-SNMP
    net-snmp-utils not installed or host #{hostname} not snmpv3 enabled
    or unknown object identifier: #{mib_oid}.
    SNMP
    abort snmp_message unless status == 0

    # Show your stuff
    if display_raw
      display_raw_table(results.split("\n")) # => Array(String)
      outfile = File.expand_path("~/tmp/raw_dump.txt")
      write_raw_results_to_file(outfile, results) if file_write # => results(String)
    else
      clear
      say_hey(hostname)
      table = {} of String => String          # => Hash(String, String)
      formatted_results = results.split("\n") # => Array(String)
      format_table(formatted_results, table)
      display_table(table, hostname, mib_oid)
    end
  end
end

App.new.run
