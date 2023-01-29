# ===============================================================================
#         FILE:  session.cr
#        USAGE:  Internal
#  DESCRIPTION:  Defines session methods.
#       AUTHOR:  Lewis E. Bogan
#      COMPANY:  Earthsea@Home
#      CREATED:  2017-12-17 15:17
#    COPYRIGHT:  (C) 2021 Lewis E. Bogan <lewis.bogan@comcast.net>
# Distributed under terms of the MIT license.
# ===============================================================================

#  Defines session methods.
module Session
  class V3Session
    record V3Credentials, user : String, auth_pass : String, priv_pass : String, auth : String, priv : String do
      include YAML::Serializable
    end

    def initialize
      @prompt = Term::Prompt.new
    end

    # Prompts the user for host credentials. This method is typically invoked
    # when the credentials are not in the configuration file.
    # ```
    # configure_session # => Session::V3Session::V3Credentials
    # ```
    #
    def configure_session
      creds = V3Credentials.new(
        @prompt.ask("Enter security name: ", required: true).to_s,
        @prompt.mask("Enter authentication phrase: ", required: true).to_s,
        @prompt.mask("Enter privacy phrase: ", required: true).to_s,
        @prompt.ask("Authentication: [MD5/SHA]", default: "SHA").to_s.upcase,
        @prompt.ask("Crypto algorithm [AES/DES]: ", default: "AES").to_s.upcase
      )
      creds
    end
  end
end
