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
  @@prompt = Term::Prompt.new

  # Creates a dummy entry.
  def build_default_config(config_path : String, config_file : String)
    Dir.mkdir_p(config_path, 0o700)
    conf = {"dummy" => {user: "username", auth_pass: "auth passphrase",
                        priv_pass: "priv passphrase", auth: "MD5/SHA",
                        crypto: "AES/DES"}}
    choice = @@prompt.yes?("Config file doesn't exist. Create it(Y/n)? ")
    build_config_file(config_file, conf) if choice
  end

  # Creates a new config file.
  def build_config_file(config_file : String, conf : Hash)
    File.open(config_file, "w") do |file|
      file.puts "# #{config_file}"
      YAML.dump(conf, file)
    end
  end

  # Adds new host to config file
  def update_config_file(hostname : String)
    print_chars('-', 60)
    config = Session::V3Session.new.configure_session
    credentials = {hostname => config}.to_yaml.gsub("---", "")
    print_chars('-', 60)
    choice = @@prompt.yes?("Save these credentials(Y/n)? ")
    Util.append_file(CONFIG_FILE, credentials) if choice
    config
  end

  def check_credentials(config_file : String) : YAML::Any
    YAML.parse(File.read(config_file))
  end

  def fetch_credentials(config_file : String, hostname : String)
    creds = YAML.parse(File.read(config_file))[hostname]
    {user: creds["user"].to_s, auth_pass: creds["auth_pass"].to_s,
     priv_pass: creds["priv_pass"].to_s, auth: creds["auth"].to_s,
     crypto: creds["crypto"].to_s}
  end
end
