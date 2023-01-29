# ===============================================================================
#         FILE:  util.cr
#        USAGE:  Internal
#  DESCRIPTION:  General purpose utilities.
#       AUTHOR:  Lewis E. Bogan
#      COMPANY:  Earthsea@Home
#      CREATED:  2020-07-31 17:45
#    COPYRIGHT:  (C) 2021 Lewis E. Bogan <lewis.bogan@comcast.net>
# Distributed under terms of the MIT license.
# ===============================================================================
module Util
  def self.date
    time = {{ (env("SOURCE_DATE_EPOCH") || `date +%s`).to_i }}
    Time.unix(time).to_s("%Y-%m-%d")
  end

  # Clears the screen using ansi codes.
  #
  # ```text
  # \e[ is the escape code
  # 2J clears the screen
  # 1;1H moves cursor to line 1, column 1
  # ```
  #
  # ```text
  # Util.clear_screen # => "\e[2J\e[1;1H]]"
  # ```
  #
  def self.clear_screen
    puts IO::Memory.new << "\e[2J\e[1;1H"
  end

  # Opens _filename_ for writing. Creates it if it doesn't exist. Overwrites _content_.
  #
  # ```
  # Util.write_file("path/test.txt", "Testing 1, 2, 3.")
  # ```
  #
  def self.write_file(filename : String, content : String)
    File.open(filename, "w", &.puts(content))
  end

  # Opens _filename_ for appending _content_.
  #
  # ```
  # Util.append_file("path/test.txt", "Testing 1, 2, 3.")
  # ```
  #
  def self.append_file(filename : String, content : String)
    File.open(filename, "a", &.puts(content))
  end

  # Checks for hostname in ARGV
  #
  # ```
  # Util.process_argv("myhost") # => "myhost"
  # ```
  #
  def self.process_argv(argv) : String
    if argv.empty?
      hostname = PROMPT.ask("Enter hostname: ").to_s
      raise Errors::BlankHostError.error if hostname.blank?
      hostname
    else
      argv[0]
    end
  end

  # Does a lookup of a host's ip address and returns it as a Socket::IPAddress
  # object. Raises an error if the hostname doesn't exist or can't be resolved.
  # Remove the ":7" part with `rstrip(":7")` to get just the ip address.
  #
  # ```
  # Util.resolve_host("example.com")                   # => ip_address:7
  # Util.resolve_host("example.com").to_s.rstrip(":7") # => ip_address
  # ```
  #
  def self.resolve_host(host)
    addrinfo = Socket::Addrinfo.resolve(
      domain: host,
      service: "echo",
      type: Socket::Type::DGRAM,
      protocol: Socket::Protocol::UDP,
    ) # => Array(Socket::Addrinfo)

    addrinfo.first?.try(&.ip_address)
  end

  # Asks for a hostname if none is given on the command line.
  #
  # ```
  # Util.check_for_host # => String
  # ```
  #
  def self.check_for_host(argv)
    hostname = process_argv(argv)
    begin
      resolve_host("#{hostname}")
    rescue ex
      Errors::InvalidHostnameError.error(ex.message)
    end
    hostname
  end

  # Runs the editor indicated by ENV["EDITOR"], nano as default.
  # Redirect the standard input, output and error IO of a process
  # using the IO of the parent process, Process::Redirect::Inherit.
  def self.edit_config_file(filename)
    Process.run(
      ENV.fetch("EDITOR", "nano"),
      args: {"#{filename}"},
      input: Process::Redirect::Inherit,
      output: Process::Redirect::Inherit,
      error: Process::Redirect::Inherit,
    )
  end

  # Runs a system-level command and returns a Tuple(Int32, String) containing
  # status, and command output or error. If _args_ is missing, it defaults to "".
  #
  # ```
  # status, result = Util.run_cmd("ls", {"-l", "-s"}) # => 0, listing
  #
  # status, result = Util.run_cmd("ls", {"-ls"}) # => 0, listing
  #
  # status, result = Util.run_cmd("ls", ["-ls"]) # => 0, listing
  #
  # status, result = Util.run_cmd("junk") # => 1, error-message about missing cmd.
  # ```
  #
  def self.run_cmd(cmd : String, args : Tuple = {""}) : Tuple(Int32, String)
    stdout_str = IO::Memory.new
    stderr_str = IO::Memory.new
    status = Process.run(cmd, args: args, output: stdout_str, error: stderr_str)
    if status.success?
      {status.exit_code, stdout_str.to_s}
    else
      {status.exit_code, stderr_str.to_s}
    end
  end

  # Overloads run_cmd taking an Array for _args_.
  def self.run_cmd(cmd : String, args : Array = [""]) : Tuple(Int32, String)
    stdout_str = IO::Memory.new
    stderr_str = IO::Memory.new
    status = Process.run(cmd, args: args, output: stdout_str, error: stderr_str)
    if status.success?
      {status.exit_code, stdout_str.to_s}
    else
      {status.exit_code, stderr_str.to_s}
    end
  end
end
