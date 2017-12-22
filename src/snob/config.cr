# ===============================================================================
#         FILE:  config.cr
#        USAGE:  Internal
#  DESCRIPTION:  Configuration.
#       AUTHOR:  Lewis E. Bogan
#      COMPANY:  Earthsea@Home
#      CREATED:  2017-12-17 15:13
#    COPYRIGHT:  (C) 2017 Lewis E. Bogan <lewis.bogan@comcast.net>
# Distributed under terms of the MIT license.
# ===============================================================================

# Defines configuration file methods. **extend self** allows these
# methods to be included in a program (class) and invoked without a namespace
# or just used as a namespace.
module Config
  extend self

  # Checks for existance of a config file and creates a dummy entry
  #    if the user answers yes.
  def check_for_config(config_path, config_file)
    unless File.exists?(config_file)
      Dir.mkdir_p(config_path, 0o700)
      #Dir.mkdir_p(File.expand_path("~/.snob/"))
      options = {"dummy" => {"user" => "username", "auth" => "auth passphrase",
                             "priv" => "priv passphrase", "crypto" => "AES/DES"}}
      choice = ask("Config file doesn't exist. Create it? ")
      build_config_file(config_file, options) if /#{choice}/i =~ "yes"
    end
  end

  # Creates a new config file.
  def build_config_file(config_file, conf)
    File.open(config_file, "w") do |file|
      file.puts "# #{config_file}"
      YAML.dump(conf, file)
    end
  end

  # Parses a YAML configuration file.
  #     Returns # => YAML::Any
  def fetch_config(config_file)
    YAML.parse(File.read(config_file))
  end
end
