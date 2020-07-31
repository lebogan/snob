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
  @@prompt = Term::Prompt.new

  # Prompts the user for host credentials. This method is typically invoked
  # when the credentials are not in the configuration file.
  # ```
  # configure_session # => NamedTuple(user: String, auth: String, priv: String, crypto: String)
  # ```
  #
  # def configure_session
  #   {user:      Myutils.ask("Enter security name: "),
  #    auth_pass: Secrets.gets(prompt: "Enter authentication phrase: "),
  #    priv_pass: Secrets.gets(prompt: "Enter privacy phrase: "),
  #    auth:      Myutils.ask("Authentication: [MD5/SHA]").upcase,
  #    crypto:    Myutils.ask("Crypto algorithm [AES/DES]: ").upcase}
  # end
  def configure_session
    {user:      @@prompt.ask("Enter security name: ", required: true).to_s,
     auth_pass: @@prompt.mask("Enter authentication phrase: ", required: true).to_s,
     priv_pass: @@prompt.mask("Enter privacy phrase: ", required: true).to_s,
     auth:      @@prompt.ask("Authentication: [MD5/SHA]", default: "SHA").to_s.upcase,
     crypto:    @@prompt.ask("Crypto algorithm [AES/DES]: ", default: "AES").to_s.upcase}
  end
end
