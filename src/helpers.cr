# ===============================================================================
#         FILE:  helpers.cr
#        USAGE:  Internal
#  DESCRIPTION:  Defines general program helper methods.
#       AUTHOR:  Lewis E. Bogan
#      COMPANY:  Earthsea@Home
#      CREATED:  2018-11-30 14:10
#    COPYRIGHT:  (C) 2018 Lewis E. Bogan <lewis.bogan@comcast.net>
# Distributed under terms of the MIT license.
# ===============================================================================

module Helpers
  extend self

  # Says hello to _hostname_.
  #
  # ```
  # Helpers.say_hey("myserver") # => "Hey, myserver!"
  # ```
  #
  def say_hey(hostname : String)
    puts "Hey #{hostname}!"
  end

  # Does a lookup of a host's ip address and returns it as a Socket::IPAddress
  # object. Raises an error if the hostname doesn't exist or can't be resolved.
  # Remove the ":7" part with `rstrip(":7")` to get just the ip address.
  #
  # ```
  # Helpers.resolve_host("example.com")                   # => ip_address:7
  # Helpers.resolve_host("example.com").to_s.rstrip(":7") # => ip_address
  # ```
  #
  def resolve_host(host)
    addrinfo = Socket::Addrinfo.resolve(
      domain: host,
      service: "echo",
      type: Socket::Type::DGRAM,
      protocol: Socket::Protocol::UDP,
    ) # => Array(Socket::Addrinfo)

    addrinfo.first?.try(&.ip_address)
  end

  # Runs the editor indicated by ENV["EDITOR"], nano as default.
  # Redirect the standard input, output and error IO of a process
  # using the IO of the parent process, Process::Redirect::Inherit.
  def edit_config_file(filename)
    Process.run(
      ENV.fetch("EDITOR", "nano"),
      args: {"#{filename}"},
      input: Process::Redirect::Inherit,
      output: Process::Redirect::Inherit,
      error: Process::Redirect::Inherit,
    )
  end
end
