# ===============================================================================
#         FILE:  snob.cr
#        USAGE:  snob [arguments...]
#  DEVELOPMENT:  crystal build|run src/snob.cr --warnings all --error-on-warnings
#      RELEASE:  crystal build --release src/snob.cr
#  DESCRIPTION:  A simple Snmp Network Object Browser.
#      OPTIONS:  ---
# REQUIREMENTS:  snmp snmp-mib-downloader
#         BUGS:  ---
#        NOTES:
#       AUTHOR:  Lewis E. Bogan
#      COMPANY:  Earthsea@Home
#      CREATED:  2017-11-10 10:19
#    COPYRIGHT:  (C) 2017-2020 Lewis E. Bogan <lewis.bogan@comcast.net>
#    GIT REPOS:  earthforge, devforge, GitHub, BitBucket
#             :  git remote add origin git@earthforge.earthsea.local:lewisb/snob.git
#             :  git remote set-url --add --push origin ssh://devforge/var/lib/git/repos/snob.git
#             :  git remote set-url --add --push origin git@github.com:lebogan/snob.git
#             :  git remote set-url --add --push origin git@bitbucket.org:lebogan/snob.git
#             :  git push -u origin master
# Distributed under terms of the MIT license.
# ===============================================================================
require "./config.cr"
require "./messages.cr"
require "./reports.cr"
require "./session.cr"
require "./snmp.cr"
require "./helpers.cr"
require "./util.cr"
require "yaml"
require "option_parser"
require "socket"
require "term-prompt"

# Allows displaying object methods during development.
class Object
  macro methods
    {{ @type.methods.map &.name.stringify }}
  end
end

# We have to rely on having net-snmp installed on our pc.
# TODO: Bind the net-snmp c library to make this app portable.
# TODO: Test, test, test!

# This struct contains the main application. It checks for command line arguments,
# valid hostname, and snmpv3 credentials.
struct App
  include Reports
  include Helpers
  include Snmp
  include Config
  include Session
  include Messages
  include Util

  private getter arguments

  # Creates a *new* method for App class.
  def initialize(@arguments : Array(String))
    @prompt = Term::Prompt.new
  end

  # Processes command-line argments via ARGV.
  def self.run(arguments = ARGV)
    new(arguments).run
  end

  # Runs the main application.
  def run
    mib_oid = "system"
    display_formatted = false
    only_values = false
    file_write = false

    OptionParser.parse do |parser|
      parser.banner = banner_message
      parser.on("-l", "--list", "List some pre-defined OIDs") do
        list_oids(Config::OIDLIST)
        exit 0
      end
      parser.on("-m OID", "--mib=OID", "Display information for this oid
                                     (Default: system)") do |oid|
        mib_oid = case
                  when OIDLIST.has_key?(oid) then Config::OIDLIST["#{oid}"]
                  when !oid.empty?           then oid
                  else
                    ""
                  end
      end
      parser.on("-d", "--dump", "Write output to file, raw only") { file_write = true }
      parser.on("-e", "--edit", "Edit global config file") do
        edit_config_file(CONFIG_FILE)
        exit 0
      end
      parser.on("-f", "--formatted", "Display as formatted table") { display_formatted = true }
      parser.on("-o", "--only-values", "Display values only (not OID = value)") { only_values = true }
      parser.on("-h", "--help", "Show this help") do
        puts parser
        exit 0
      end
      parser.on("-v", "--version", "Show version") do
        puts about
        exit 0
      end
      parser.invalid_option { |flag| abort invalid_message(flag) }
      parser.missing_option { |flag| abort missing_message(flag) }
    end

    hostname = check_for_host(arguments)

    check_for_config(Config::CONFIG_PATH, Config::CONFIG_FILE)

    # Checks for the existence of a valid config file and tests if host
    # is in it. Otherwise, asks for manual entry of credentials and
    # adds them to existing config file.
    # NOTE: {hostname => config} is a Hash(String => Hash(String, String))
    if File.exists?(Config::CONFIG_FILE) && fetch_config(Config::CONFIG_FILE)["#{hostname}"]? != nil
      config = fetch_config(Config::CONFIG_FILE)["#{hostname}"] # => YAML::Any
    else
      config = update_config_file(hostname)
    end

    # Creates an Snmp session object and invokes the walk_mib3 method on the object,
    # host_session, using 'system' oid if the --mib flag is missing.
    host_session = Snmp.new(
      config["auth_pass"].to_s,
      config["priv_pass"].to_s,
      config["user"].to_s,
      config["auth"].to_s.upcase,
      config["crypto"].to_s.upcase) # => Snmp
    output_format = only_values ? "vq" : "QUsT"
    status, results = host_session.walk_mib3(hostname, mib_oid, output_format)
    abort snmp_message(hostname, mib_oid) unless status == 0

    # Show your stuff
    case
    when display_formatted
      Util.clear_screen
      say_hey(hostname)
      table = {} of String => String # => Hash(String, String)
      format_table(results.split("\n"), table)
      display_table(table, hostname, mib_oid)
    when file_write
      Dir.mkdir_p(Config::OUT_PATH) unless Dir.exists?(Config::OUT_PATH)
      Util.write_file(OUT_FILE, results)
    else
      display_raw_table(results.split("\n")) # => Array(String)
    end
  end
end

App.run
