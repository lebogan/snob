# ===============================================================================
#         FILE:  utils.cr
#        USAGE:  Internal
#  DESCRIPTION:  General program utilities.
#       AUTHOR:  Lewis E. Bogan
#      COMPANY:  Earthsea@Home
#      CREATED:  2017-12-16 13:28
#    COPYRIGHT:  (C) 2017 Lewis E. Bogan <lewis.bogan@comcast.net>
# Distributed under terms of the MIT license.
# ===============================================================================

# Defines general program utility methods. **extend self** allows these
# methods to be included in a program (class) and invoked without a namespace
# or just used as a namespace.
module Utils
  extend self

  # Displays prompt and cursor all on one line if prompt ends with a space,
  # otherwise displays prompt string and a newline.
  #
  # ```
  # prompt_msg("Enter something: ") # => Nil
  # ```
  #
  private def prompt_msg(prompt : Tuple)
    prompt[0].ends_with?(" ") ? print(*prompt) : puts(*prompt)
  end

  # Runs a system-level command and returns a Tuple(Int32, String) containing
  # status, and command output or error.
  #
  # ```
  # status, result = Utils.run_cmd("ls", {"-ls"}) # => 0, listing
  # ```
  #
  def run_cmd(cmd : String, args : Tuple) : Tuple(Int32, String)
    stdout_str = IO::Memory.new
    stderr_str = IO::Memory.new
    status = Process.run(cmd, args: args, output: stdout_str, error: stderr_str)
    if status.success?
      {status.exit_code, stdout_str.to_s}
    else
      {status.exit_code, stderr_str.to_s}
    end
  end

  # Clears the screen using ansi codes.
  #
  #```text
  # \e[ is the escape code
  # 2J clears the screen
  # 1;1H moves cursor to line 1, column 1
  #```
  #
  #```text
  # clear_screen # => "\e[2J\e[1;1H]]"
  #```
  #
  def clear_screen
    puts IO::Memory.new << "\e[2J\e[1;1H"
  end

  # Prompts for user input displaying the passed prompt in _args_.
  #
  # ```
  # Utils.ask("Enter something: ") # => "whatever you entered"
  # ```
  #
  # ```text
  # $ Enter something: _
  # ```
  #
  def ask(*args) : String
    prompt_msg(args)
    gets.to_s
  end

  # Gets passphrase without echoing it to the screen.
  #
  # ```
  # Question.ask_pass("Enter passphrase: ") # => Tuple(String?)
  # ```
  #
  # ```text
  # $ Enter passphrase: _ <no echo>
  # ```
  #
  def askpass(*args) : Tuple(String?)
    prompt_msg(args)
    passphrase = STDIN.noecho &.gets.try &.chomp
    puts
    {passphrase}
  end

  # Gets a single character (no newline) for use in paging long displays
  # and other single character prompts.
  #
  # ```
  # Utils.ask_char("press 'q' to quit ") # => 'q'
  # ```
  #
  # ```text
  # $ press 'q' to quit _
  # ```
  #
  # NOTE: see Reports.display_table_info for usage.
  def ask_char(*args) : Char?
    prompt_msg(args)
    STDIN.raw &.read_char
  end

  # Prompts for an agreement in the form (y/n) or whatever else. Any
  # answer starting with 'y' or 'Y' is evaluated true. Anything else
  # is false.
  #
  # ```
  # Utils.agree?("Are you sure(y/n)?: ") # => true | false
  # ```
  #
  # ```text
  # $ Are you sure(y/n)?: _
  # ```
  #
  def agree?(*args) : Bool
    prompt_msg(args)
    gets =~ /^y/i ? true : false
  end

  # Truncates a _text_ string longer than _length_ characters and prints
  # a _truncate_ _string_ (defaults to '...') in place of the removed text.
  # Defaults to # 48 characters.
  #
  # ```
  # Utils.truncate("hello, world", 10, "...") # => hello, ...
  # ```
  #
  def truncate(text : String, length = 48, truncate_string = "...") : String
    l = length - truncate_string.size
    text.size > length ? (text[0...l] + truncate_string) : text
  end

  # Reads _filename_.
  def read_file(filename : String)
    result = File.read_lines(filename)
    result # => Array(String)
  end

  # Opens _filename_ for writing. Creates it if it doesn't exist. Overwrites _content_.
  def write_file(filename : String, content : String)
    File.open(filename, "w") do |file|
      file.puts content
    end
  end

  # Says hello to _hostname_.
  #
  # ```
  # Utils.say_hey("myserver") # => "Hey, myserver!"
  # ```
  #
  def say_hey(hostname : String)
    puts "Hey #{hostname}!"
  end
end
