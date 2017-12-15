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

  # Checks for existance of a config file and creates a dummy entry 
  #    if the user answers yes.
  def check_for_config(config_file)
    unless File.exists?(config_file)
      choice = ask("Build a new config file? ")
      options = {"dummy" => {"user" => "username", "auth" => "auth passphrase",
                             "priv" => "priv passphrase", "crypto" => "AES/DES"}}
      build_config_file(config_file, options) if /#{choice}/i =~ "yes"
    end
  end

  # Creates a new config file.
  def build_config_file(config_file, conf)
    File.open(config_file, "w") do |file|
      file.puts "# #{config_file}"
      YAML.dump(conf, file)
    end
  end

  # Parses a YAML configuration file.
  #     Returns # => YAML::Any
  def fetch_config(config_file)
    YAML.parse(File.read(config_file))
  end

  # Adds new session credentials to config file.
  def add_session(config_file, conf)
    File.open(config_file, "a") do |file|
      file.puts conf
    end
  end

  # Prompts the user for host credentials. This method is typically invoked
  # when the credentials are not in the configuration file.
  #     Returns #  => Tuple(Hash(Symbol, String))
  def configure_session
    conf = {} of String => String
    conf["user"] = ask("Enter security name: ")
    conf["auth"] = askpass("Enter authentication phrase: ")[0].to_s
    conf["priv"] = askpass("Enter privacy phrase: ")[0].to_s
    conf["crypto"] = ask("Crypto algorithm [AES/DES]: ").upcase
    {conf}
  end

  # Truncates a string longer than length characters and prints _..._ in the 
  # place of the removed text. Defaults to 48 characters.
  def truncate(text, length = 48, truncate_string = "...")
    l = length - truncate_string.size
    (text.size > length ? text[0..l] + truncate_string : text) if text
  end

  # Says hello to _hostname_.
  def say_hey(hostname)
    puts "Hey #{hostname}!"
  end

  # Lists some useful oids.
  def list_oids
    puts <<-OIDS
    Here are some useful mib oids. Copy and paste as needed.
    lldp port: 1.0.8802.1.1.2.1.4.1.1.9
    arp cache: ipNetToPhysicalPhysAddress
    memory usage: memory
    disk volumes: dsk
    OIDS
  end
end


