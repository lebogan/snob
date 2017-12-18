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

  # Runs a system-level commands and returns a status and results object.
  #     Returns # => Tuple{Int32, String}
  def run_cmd(cmd, args)
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
  # \e[ is the escape
  # 2J clear screen
  # 1;1H move cursor to line 1, column 1
  def clear_screen
    print "\e[2J\e[1;1H"
  end

  # ditto
  def clear
    puts IO::Memory.new << "\e[2J\e[1;1H"
  end

  # Prompts for user input displaying the passed prompt in **args*.
  #     Returns #  => String
  def ask(*args)
    print(*args)
    gets.to_s
  end

  # Gets passphrase without echoing it to the screen. Uses io/console.cr.
  #     Returns # => Tuple(String)
  def askpass(*args)
    print(*args)
    passphrase = STDIN.noecho &.gets.try &.chomp
    puts
    {passphrase}
  end

  # Gets a single character for use in paging long displays.
  #    Returns # => Char
  # To break out of a block:
  # ```
  # choice = page("\n -- press any key to continue or q to quit -- ")
  # choice == 'q' ? break : next
  # ```
  # NOTE: see Reports.display_table_info for usage.
  def page(*args)
    args[0].to_s.ends_with?(" ") ? print(*args) : puts(*args)
    STDIN.raw &.read_char
  end

  # Truncates a string longer than length characters and prints _..._ in the
  # place of the removed text. Defaults to 48 characters.
  def truncate(text, length = 48, truncate_string = "...")
    l = length - truncate_string.size
    (text.size > length ? text[0...l] + truncate_string : text) if text
  end

  # Reads a file.
  def read_file(filename)
    result = File.read_lines(filename)
    result # => Array(String)
  end

  # Says hello to _hostname_.
  def say_hey(hostname)
    puts "Hey #{hostname}!"
  end
end
