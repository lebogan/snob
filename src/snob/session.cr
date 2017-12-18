#===============================================================================
#         FILE:  session.cr
#        USAGE:  Internal
#  DESCRIPTION:  
#       AUTHOR:  Lewis E. Bogan
#      COMPANY:  Earthsea@Home
#      CREATED:  2017-12-17 15:17
#    COPYRIGHT:  (C) 2017 Lewis E. Bogan <lewis.bogan@comcast.net>
# Distributed under terms of the MIT license.
#===============================================================================

# Defines session methods. **extend self** allows these
# methods to be included in a program (class) and invoked without a namespace
# or just used as a namespace.
module Session
  extend self

  # Adds new session credentials to config file.
  def add_session(config_file, conf)
    File.open(config_file, "a") do |file|
      file.puts conf
    end
  end

  # Prompts the user for host credentials. This method is typically invoked
  # when the credentials are not in the configuration file.
  #     Returns #  => Tuple(Hash(Symbol, String))
  def configure_session
    conf = {} of String => String
    conf["user"] = ask("Enter security name: ")
    conf["auth"] = askpass("Enter authentication phrase: ")[0].to_s
    conf["priv"] = askpass("Enter privacy phrase: ")[0].to_s
    conf["crypto"] = ask("Crypto algorithm [AES/DES]: ").upcase
    {conf}
  end
end
