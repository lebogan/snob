# ===============================================================================
#         FILE:  util.cr
#        USAGE:  Internal
#  DESCRIPTION:  General purpose utilities.
#       AUTHOR:  Lewis E. Bogan
#      COMPANY:  Earthsea@Home
#      CREATED:  2020-07-31 17:45
#    COPYRIGHT:  (C) 2020 Lewis E. Bogan <lewis.bogan@comcast.net>
# Distributed under terms of the MIT license.
# ===============================================================================
module Util
  def self.date
    time = {{ (env("SOURCE_DATE_EPOCH") || `date +%s`).to_i }}
    Time.unix(time).to_s("%Y-%m-%d")
  end

  # Displays prompt and cursor all on one line if prompt ends with a space,
  # otherwise displays prompt string, a newline, and then the cursor.
  #
  # ```
  # prompt_msg("Enter something: ") # => Nil
  # ```
  #
  # ```text
  # $ Enter something: _
  # ```
  #
  def self.prompt_msg(prompt : Tuple)
    prompt[0].ends_with?(" ") ? print(*prompt) : puts(*prompt)
  end

  # Gets a single character (no newline) for use in paging long displays
  # and other single character prompts.
  #
  # ```
  # Myutils.ask_char("press 'q' to quit ") # => 'q'
  # ```
  #
  # ```text
  # $ press 'q' to quit _
  # ```
  #
  def self.ask_char(*args) : Char?
    prompt_msg(args)
    STDIN.raw &.read_char
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
  # Myutils.clear_screen # => "\e[2J\e[1;1H]]"
  # ```
  #
  def self.clear_screen
    puts IO::Memory.new << "\e[2J\e[1;1H"
  end

  # Returns an array containing the contents of _filename_.
  #
  # ```
  # Myutils.read_file("./src/spec_helper.cr") # => Array(String)
  # ```
  #
  def self.read_file(filename : String) : Array(String)
    File.read_lines(filename)
  end

  # Opens _filename_ for writing. Creates it if it doesn't exist. Overwrites _content_.
  #
  # ```
  # Myutils.write_file("path/test.txt", "Testing 1, 2, 3.")
  # ```
  #
  def self.write_file(filename : String, content : String)
    File.open(filename, "w") { |file| file.puts content }
  end

  # Opens _filename_ for appending _content_.
  #
  # ```
  # Myutils.append_file("path/test.txt", "Testing 1, 2, 3.")
  # ```
  #
  def self.append_file(filename : String, content : String)
    File.open(filename, "a") { |file| file.puts content }
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

  # Runs a system-level command and returns a Tuple(Int32, String) containing
  # status, and command output or error. If _args_ is missing, it defaults to "".
  #
  # ```
  # status, result = Myutils.run_cmd("ls", {"-l", "-s"}) # => 0, listing
  #
  # status, result = Myutils.run_cmd("ls", {"-ls"}) # => 0, listing
  #
  # status, result = Myutils.run_cmd("ls", ["-ls"]) # => 0, listing
  #
  # status, result = Myutils.run_cmd("junk") # => 1, error-message about missing cmd.
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
