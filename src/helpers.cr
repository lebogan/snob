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

  # Checks for hostname in ARGV
  #
  # ```
  # Helpers.process_argv("myhost") # => "myhost"
  # ```
  #
  def process_argv(argv) : String
    prompt = Term::Prompt.new
    if argv.empty?
      hostname = prompt.ask("Enter hostname: ").to_s
      abort blank_host_message if hostname.blank?
      hostname
    else
      argv[0]
    end
  end

  # Asks for a hostname if none is given on the command line.
  #
  # ```
  # Helpers.check_for_host # => String
  # ```
  #
  def check_for_host(argv)
    hostname = process_argv(argv)

    # Checks if host exists on this network.
    begin
      resolve_host("#{hostname}")
    rescue ex
      abort ex.message
    end
    hostname
  end

  # Prints a line of characters for display formatting, defaults to 20 dashes.
  #
  # ```
  # Helpers.print_chars('*', 10) # => "**********"
  # Helpers.print_chars          # => "--------------------"
  # ```
  #
  def print_chars(character : Char = '-', number : Int32 = 20)
    puts "%s" % character * number
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
