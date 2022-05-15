# ===============================================================================
#         FILE:  cli.cr
#        USAGE:  Internal
#  DESCRIPTION:  The actual command line interface.
#       AUTHOR:  Lewis E. Bogan
#      COMPANY:  Earthsea@Home
#      CREATED:  2022-05-15 16:36
#    COPYRIGHT:  (C) 2022 Lewis E. Bogan <lewis.bogan@comcast.net>
# Distributed under terms of the MIT license.
# ===============================================================================

require "./*"

# This class contains the main application. It checks for command line arguments,
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

  # Runs the command-line interface.
  def run
    mib_oid = "system"
    defaults = {"display_formatted" => false, "only_values" => false,
                "dump_file" => false}

    OptionParser.parse do |parser|
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
                  else
                    mib_oid
                  end
      end
      parser.on("-d", "--dump", "Write output to file, raw only by default") { defaults["dump_file"] = true }
      parser.on("-e", "--edit", "Edit global config file") do
        edit_config_file(CONFIG_FILE)
        exit 0
      end
      parser.on("-f", "--formatted", "Display as formatted table") { defaults["display_formatted"] = true }
      parser.on("-o", "--only-values", "Display values only (not OID = value)") { defaults["only_values"] = true }
      parser.separator("\nGeneral options:")
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

    # Checks for the existence of a valid config file and tests if host
    # is in it. Otherwise, asks for manual entry of credentials and
    # adds them to existing config file.
    unless File.exists?(CONFIG_FILE)
      build_default_config(CONFIG_PATH, CONFIG_FILE)
    end

    hostname = check_for_host(arguments)

    if check_credentials(CONFIG_FILE)["#{hostname}"]? != nil
      creds = fetch_credentials(CONFIG_FILE, "#{hostname}") # => NamedTuple(Symbol, String...)
    else
      puts "'#{hostname}' is not in config file. Configuring ..."
      creds = update_config_file(hostname)
    end

    # Creates an Snmp session object and invokes the walk_mib3 method on the object,
    # host_session, using 'system' oid if the --mib flag is missing.
    host_session = Snmp.new(creds[:user], creds[:auth_pass], creds[:priv_pass], creds[:auth], creds[:crypto])
    output_format = defaults["only_values"] ? "vq" : "QUsT"
    status, results = host_session.walk_mib3(hostname, mib_oid, output_format)
    abort snmp_message(hostname, mib_oid) unless status == 0

    # Show your stuff
    case
    when defaults["display_formatted"]
      show_formatted(hostname, results, mib_oid)
    when defaults["dump_file"]
      Dir.mkdir_p(OUT_PATH) unless Dir.exists?(OUT_PATH)
      Util.write_file(OUT_FILE, results)
    else
      show_raw(results)
    end
  end
end
