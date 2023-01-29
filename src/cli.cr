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
class App
  private getter arguments

  # Creates a *new* method for App class.
  def initialize(@arguments : Array(String))
    @prompt = Term::Prompt.new
  end

  # Processes command-line argments via ARGV.
  def self.run(arguments = ARGV)
    new(arguments).run
  end

  # Creates an Snmp session object and invokes the walk_mib3 method on the object,
  # host_session, using 'system' oid if the --mib flag is missing.
  def process_session(hostname, creds, opts)
    host_session = Snmp::Snmp.new(creds.user, creds.auth_pass, creds.priv_pass,
      creds.auth, creds.priv)
    output_format = opts.only_values? ? "vq" : "QUsT"
    status, results = host_session.walk_mib3(hostname, opts.mib_oid, output_format)
    Errors::SnmpError.error(hostname, opts.mib_oid) unless status == 0
    results
  end

  # Runs the command-line interface.
  def run
    opts = Options.parse_opts(arguments)

    # Checks for the existence of a valid config file and tests if host
    # is in it. Otherwise, asks for manual entry of credentials and
    # prompts to add them to existing config file.
    unless File.exists?(CONFIG_FILE)
      Config.build_default_config(CONFIG_PATH, CONFIG_FILE)
      Messages.print_default_config_message(CONFIG_FILE)
    end

    hostname = Util.check_for_host(arguments)

    if Config.check_credentials(CONFIG_FILE)["#{hostname}"]? != nil
      creds = Registry.get hostname
    else
      puts "'#{hostname}' is not in config file. Configuring ..."
      creds = Config.update_config_file(hostname)
    end

    # Show your stuff
    results = process_session(hostname, creds, opts)
    Reports.print_results(hostname, results, opts)
  end
end
