# ===============================================================================
#         FILE:  session.cr
#        USAGE:  Internal
#  DESCRIPTION:
#       AUTHOR:  Lewis E. Bogan
#      COMPANY:  Earthsea@Home
#      CREATED:  2017-12-17 15:17
#    COPYRIGHT:  (C) 2017 Lewis E. Bogan <lewis.bogan@comcast.net>
# Distributed under terms of the MIT license.
# ===============================================================================

# Defines session methods. **extend self** allows these
# methods to be included in a program (class) and invoked without a namespace
# or just used as a namespace.
module Session
  extend self

  # Adds new session _credentials_ to config file.
  def add_session(config_file : String, credentials : String)
    File.open(config_file, "a") { |file| file.puts credentials }
  end

  # Prompts the user for host credentials. This method is typically invoked
  # when the credentials are not in the configuration file.
  def configure_session : Tuple(Hash(String, String))
    conf = {} of String => String
    conf["user"] = ask("Enter security name: ")
    conf["auth"] = Secrets.gets prompt: "Enter authentication phrase: " 
    conf["priv"] = Secrets.gets prompt: "Enter privacy phrase: "
    conf["crypto"] = ask("Crypto algorithm [AES/DES]: ").upcase
    {conf}
  end
end
