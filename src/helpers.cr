#===============================================================================
#         FILE:  helpers.cr
#        USAGE:  Internal
#  DESCRIPTION:  General helper methods.
#       AUTHOR:  Lewis E. Bogan
#      COMPANY:  Earthsea@Home
#      CREATED:  2018-11-30 14:10
#    COPYRIGHT:  (C) 2018 Lewis E. Bogan <lewis.bogan@comcast.net>
# Distributed under terms of the MIT license.
#===============================================================================

# Defines general program helper methods. **extend self** allows these
# methods to be included in a program (class) and invoked without a namespace
# or just used as a namespace.
module Helpers
  extend self

  # Displays prompt and cursor all on one line if prompt ends with a space,

  # Says hello to _hostname_.
  #
  # ```
  # Utils.say_hey("myserver") # => "Hey, myserver!"
  # ```
  #
  def say_hey(hostname : String)
    puts "Hey #{hostname}!"
  end

  # Checks for hostname in ARGV
  #
  # ```
  # Utils.process_argv("myhost") # => "myhost"
  # ```
  #
  def process_argv(argv) : String
    if argv.empty?
      hostname = Myutils.ask("Enter hostname: ")
      abort blank_host_message if hostname.blank?
      hostname
    else
      argv[0]
    end
  end

  # Prints a line of characters for display, defaults to 20 dashes.
  #
  # ```
  # Utils.print_chars('*', 10) # => "**********"
  # Utils.print_chars          # => "--------------------"
  # ```
  #
  def print_chars(character : Char = '-', number : Int32 = 20)
    puts "%s" % character * number
  end
end
