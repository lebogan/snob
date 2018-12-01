# ===============================================================================
#         FILE:  session.cr
#        USAGE:  Internal
#  DESCRIPTION:  Defines session methods.
#       AUTHOR:  Lewis E. Bogan
#      COMPANY:  Earthsea@Home
#      CREATED:  2017-12-17 15:17
#    COPYRIGHT:  (C) 2017 Lewis E. Bogan <lewis.bogan@comcast.net>
# Distributed under terms of the MIT license.
# ===============================================================================

#  Defines session methods.
module Session
  extend self

  # Prompts the user for host credentials. This method is typically invoked
  # when the credentials are not in the configuration file.
  def configure_session : Tuple(Hash(String, String))
    conf = {} of String => String
    conf["user"] = Myutils.ask("Enter security name: ")
    conf["auth"] = Secrets.gets prompt: "Enter authentication phrase: "
    conf["priv"] = Secrets.gets prompt: "Enter privacy phrase: "
    conf["crypto"] = Myutils.ask("Crypto algorithm [AES/DES]: ").upcase
    {conf}
  end
end
