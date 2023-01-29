# ===============================================================================
#         FILE:  config.cr
#        USAGE:  Internal
#  DESCRIPTION:  Defines configuration file methods.
#       AUTHOR:  Lewis E. Bogan
#      COMPANY:  Earthsea@Home
#      CREATED:  2017-12-17 15:13
#    COPYRIGHT:  (C) 2021 Lewis E. Bogan <lewis.bogan@comcast.net>
# Distributed under terms of the MIT license.
# ===============================================================================

# Defines configuration file methods.
module Config
  extend self

  # Creates a dummy entry.
  def build_default_config(config_path : String, config_file : String)
    conf = {"dummy" => {user: "username", auth_pass: "auth passphrase",
                        priv_pass: "priv passphrase", auth: "MD5/SHA",
                        priv: "AES/DES"}}
    Dir.mkdir_p(config_path, 0o700) unless Dir.exists?(config_path)
    File.open(config_file, "w") do |file|
      file.puts "# #{config_file}"
      YAML.dump(conf, file)
    end
  rescue ex
    Errors::BadFileError.error(ex.message)
  end

  # Adds new host credentials to config file # => config.
  def update_config_file(hostname : String)
    Reports.print_chars('-', 60)
    config = Session::V3Session.new.configure_session
    credentials = {hostname => config}.to_yaml.gsub("---", "")
    Reports.print_chars('-', 60)
    choice = PROMPT.yes?("Save these credentials? ")
    Util.append_file(CONFIG_FILE, credentials) if choice
    config
  end

  def check_credentials(config_file : String) : YAML::Any
    YAML.parse(File.read(config_file))
  end
end
