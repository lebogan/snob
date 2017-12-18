require "spec"
require "../src/snob/utils"
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
