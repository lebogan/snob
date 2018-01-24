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
#     GIT REPO:  https://github.com/lebogan/snob.git
#             :  git remote add origin https://github.com/lebogan/snob.git
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

# This struct contains the main application. It checks for command line arguments,
# valid hostname, and snmpv3 credentials.
#
# We have to rely on having net-snmp installed on our pc.
# TODO: Bind the net-snmp c library to make this app portable.
# TODO: Test, test, test!
struct App
  include Reports
  include Utils
  include Snmp
  include Config
  include Session
  include Messages

  OIDLIST = {arp:    "ipNetToPhysicalPhysAddress",
             lldp:   "1.0.8802.1.1.2.1.4.1.1.9",
             sys:    "system",
             mem:    "memory",
             dsk:    "dskTable",
             ifdesc: "ifDescr",
             distro: "ucdavis.7890.1.4",
             temp:   "lmTempSensorsDevice",
  } # => NamedTuple(Symbol, String...)

  CONFIG_PATH = File.expand_path("~/.snob/")
  CONFIG_FILE = File.expand_path("~/.snob/snobrc.yml")
  OUTDIR      = File.expand_path("~/tmp")
  OUTFILE     = File.expand_path("~/tmp/raw_dump.txt")

  # Runs the main application.
  def run
    mib_oid = ""
    display_formatted = false
    file_write = false

    OptionParser.parse! do |parser|
      parser.banner = banner_message
      parser.on("-l", "--list", "List some pre-defined OIDs") do
        list_oids(OIDLIST)
        exit 0
      end
      parser.on("-m OID", "--mib=OID", "Display information for this oid
                                     (Default: system)") do |oid|
        mib_oid = case
                  when OIDLIST.has_key?(oid) then OIDLIST["#{oid}"]
                  when !oid.empty?           then oid
                  else                            "system"
                  end
      end
      parser.on("-d", "--dump", "Write output to file, raw only") { file_write = true }
      parser.on("-f", "--formatted", "Display formatted output") { display_formatted = true }
      parser.on("-h", "--help", "Show this help") do
        puts parser
        exit 0
      end
      parser.on("-v", "--version", "Show version") do
        puts "snob v#{Snob::VERSION}"
        exit 0
      end
      parser.invalid_option do |flag|
        abort invalid_message(flag)
      end
      parser.missing_option do |flag|
        abort missing_message(flag)
      end
    end

    # Asks for a hostname if none is given on the command line.
    if ARGV.empty?
      hostname = ask("Enter hostname: ")
      abort blank_host_message if hostname.blank?
    else
      hostname = ARGV[0]
    end

    # Checks if host exists on this network
    args = {"-c", "2", "#{hostname}"} # => Tuple(String, String, String)
    status, result = run_cmd("ping", args)
    abort ping_message(hostname) unless status == 0

    # Checks for existence of a config file and creates a dummy entry
    #    if the user answers yes.
    check_for_config(CONFIG_PATH, CONFIG_FILE)

    # Checks for the existence of a valid config file and tests if host
    #   is in it. Otherwise, asks for manual entry of credentials and
    #   adds them to existing config file.
    # NOTE: {hostname => config} => Hash(String, Hash(String, String))
    if File.exists?(CONFIG_FILE) && fetch_config(CONFIG_FILE)["#{hostname}"]? != nil
      config = fetch_config(CONFIG_FILE)["#{hostname}"] # => YAML::Any
    else
      puts "'#{hostname}' is not in config file."
      puts "%s" % '-' * 35
      config = configure_session[0]                              # => Hash(String, NamedTuple)
      credentials = {hostname => config}.to_yaml.gsub("---", "") # => String
      puts "%s" % '-' * 35
      puts "You entered: %s" % credentials
      choice = agree?("Save these credentials(y/n)? ")
      add_session(CONFIG_FILE, credentials) if choice
    end

    # Creates a Snmp object and invokes the walk_mib3 method on the Snmp object, host,
    # using 'system' oid if the --mib flag is missing.
    #     Returns # => Tuple{Int32, String}
    mib_oid = "system" if mib_oid.empty?
    host = Snmp.new(
      config["auth"].to_s,
      config["priv"].to_s,
      config["user"].to_s,
      config["crypto"].to_s.upcase) # => Snmp
    status, results = host.walk_mib3(hostname, mib_oid)
    abort snmp_message(hostname, mib_oid) unless status == 0

    # Show your stuff
    if display_formatted
      clear_screen
      say_hey(hostname)
      table = {} of String => String # => Hash(String, String)
      format_table(results.split("\n"), table)
      display_table(table, hostname, mib_oid)
    else
      if file_write
        Dir.mkdir_p(OUTDIR) unless Dir.exists?(OUTDIR)
        write_file(OUTFILE, results)
      end
      display_raw_table(results.split("\n")) # => Array(String)
    end
  end
end

App.new.run
