# ===============================================================================
#         FILE:  options.cr
#        USAGE:  Internal
#  DESCRIPTION:
#       AUTHOR:  Lewis E. Bogan
#      COMPANY:  Earthsea@Home
#      CREATED:  2023-01-29 14:35
#    COPYRIGHT:  (C) 2023 Lewis E. Bogan <lewis.bogan@comcast.net>
# Distributed under terms of the MIT license.
# ===============================================================================

module Options
  class Opts
    property? display_formatted : Bool = false
    property? only_values : Bool = false
    property? dump_file : Bool = false
    property mib_oid : String = "system"
  end

  def self.parse_opts(arguments, opts = Opts.new)
    OptionParser.parse do |parser|
      parser.banner = Messages.print_banner
      parser.on("-l", "--list", "List some pre-defined OIDs") { Reports.list_oids(OIDLIST); exit 0 }
      parser.on("-m OID", "--mib=OID", "Display information for this oid [Default: system]") do |oid|
        opts.mib_oid = case
                       when OIDLIST.has_key?(oid) then OIDLIST["#{oid}"]
                       when !oid.empty?           then oid
                       else
                         opts.mib_oid
                       end
      end
      parser.on("-d", "--dump", "Write output to file, raw only by default") { opts.dump_file = true }
      parser.on("-e", "--edit", "Edit global config file") { Util.edit_config_file(CONFIG_FILE); exit 0 }
      parser.on("-f", "--formatted", "Display as formatted table") { opts.display_formatted = true }
      parser.on("-o", "--only-values", "Display values only (not OID = value)") { opts.only_values = true }
      parser.separator("\nGeneral options:")
      parser.on("-h", "--help", "Show this help") { Messages.print_help(parser) }
      parser.on("-v", "--version", "Show version") { Messages.print_version }
      parser.invalid_option { |flag| raise Errors::InvalidOptionError.error(flag) }
      parser.missing_option { |flag| raise Errors::MissingOptionError.error(flag) }
    end
    opts
  end
end
