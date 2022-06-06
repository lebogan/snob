# ===============================================================================
#         FILE:  reports.cr
#        USAGE:  Internal
#  DESCRIPTION:  Reporting utilities.
#       AUTHOR:  Lewis E. Bogan
#      COMPANY:  Earthsea@Home
#      CREATED:  2017-12-16 13:29
#    COPYRIGHT:  (C) 2021 Lewis E. Bogan <lewis.bogan@comcast.net>
# Distributed under terms of the MIT license.
# ===============================================================================

FORMATTED_PAGE_SIZE = 15
RAW_PAGE_SIZE       = 20
SEPERATOR           = "-------------------+-------------------------------------------------"

# Displays the results of a snmpwalk operation either raw or formatted.
module Reports
  # Prints a line of characters for display formatting, defaults to 20 dashes.
  #
  # ```
  # Reports.print_chars('*', 10) # => "**********"
  # Reports.print_chars          # => "--------------------"
  # ```
  #
  def print_chars(character : Char = '-', number : Int32 = 20)
    puts "%s" % character * number
  end

  # Truncates a _text_ string longer than _length_ characters and prints
  # a _truncate_ _string_ (defaults to '...') in place of the removed text.
  # Defaults to # 48 characters.
  #
  # ```
  # Reports.truncate("hello, world", 10, "...") # => hello, ...
  # ```
  #
  def truncate(text : String, length = 48, trunc_string = "...") : String
    text.size > length ? "#{text[0...length - trunc_string.size]}#{trunc_string}" : text
  end

  # Capitalizes only the first word in a string, leaving the rest untouched. This
  # preserves the words I want capitalized intentionally.
  #
  # ```
  # Reports.capitalize!("my dog has Fleas") # => "My dog has Fleas"
  # ```
  def capitalize!(string : String) : String
    String.build { |str| str << string[0].upcase << string[1..string.size] }
  end

  # Adds a period to the end of a string if no terminating punctuation (?, !, .)
  # is present.
  #
  # ```
  # Reports.punctuate!("let's end this")  # => "let's end this."
  # Reports.punctuate!("let's end this!") # => "let's end this!"
  # Reports.punctuate!("let's end this?") # => "let's end this?"
  # ```
  def punctuate!(string : String) : String
    case string
    when .ends_with?('.'), .ends_with?('?'), .ends_with?('!')
      string
    else
      string.insert(-1, '.')
    end
  end

  def show_formatted(hostname, results, mib_oid)
    Util.clear_screen
    say_hey(hostname)
    table = {} of String => String # => Hash(String, String)
    format_table(results.split("\n"), table)
    display_table(table, hostname, mib_oid)
  end

  def show_raw(results)
    Util.clear_screen
    display_raw_table(results.split("\n")) # => Array(String)
  end

  # Displays the formatted table information, removes quotes from info string variable.
  def display_formatted_table(formatted_table : Hash | NamedTuple)
    page_count = 1
    formatted_table.each do |label, info|
      printf("%-18s |%s\n", label, info.delete("\""))
      puts SEPERATOR
      page_count += 1
      if page_count % FORMATTED_PAGE_SIZE == 0
        PROMPT.yes?("Continue?") ? next : break
      end
    end
    puts "\n"
  end

  # Displays the raw unformatted snmpwalk results.
  def display_raw_table(table : Array(String))
    page_count = 1
    table.each do |entry|
      puts entry
      page_count += 1
      if page_count % RAW_PAGE_SIZE == 0
        PROMPT.yes?("Continue?") ? next : break
      end
    end
    puts "\n\n"
  end

  # Displays the report header.
  def display_header(hostname : String, header : Tuple, oid : String)
    print_chars('=', 67)
    puts "#{hostname.upcase} - #{oid}"
    print_chars('-', 67)
    printf("%-18s | %s\n", header[0], header[1])
    print_chars('=', 67)
  end

  # Formats the appropriate oid header.
  def format_header(oid : String) : Tuple(String, String)
    case
    when oid.includes?("1.0.8802.1.1.2.1.4.1.1.9")
      {"port.instance", "remote host"}
    when oid.includes?("ipNetToPhysicalPhysAddress")
      {"ip address", "mac address"}
    else
      {"label", "value"}
    end
  end

  # Displays header and formatted table information.
  def display_table(formatted_table : Hash, hostname : String, oid : String)
    header = format_header(oid) # => Tuple(String, String, String)
    display_header(hostname, header, oid)
    display_formatted_table(formatted_table)
  end

  # Formats the table into label and info.
  def format_table(results : Array, table : Hash) : Hash(String, String)
    results.each do |entry|
      if entry.split("=").size > 1
        label = format_label(entry)
        info = truncate(entry.split("=")[1]).to_s
        table[label] = info
      end
    end
    table # => Hash(String, String)
  end

  # Formats the label depending on which oid it represents.
  def format_label(entry : String) : String
    label = entry.split("=")[0].split(/\"/)
    case
    when label[0].includes?("ipNetToPhysicalPhysAddress") # arp table
      label[-2].to_s
    when label[0].includes?("iso.0.8802.1.1.2.1.4.1.1.9") # lldp
      label[0].split(/\./)[-2..-1].join(".").to_s
    when label[0].includes?("ucdavis.7890.1.4") # Linux distro
      "Linux distro"
    when label[0].includes?("enterprises.11.2.14.11.1.2.4.1.4.1") # hp_description
      "hp switch desc"
    else
      label[0].to_s
    end
  end

  # Lists some useful difficult-to-remember oids.
  #
  # ```text
  # ===================================================================
  # OIDS - Included pre-defined object identifiers
  # -------------------------------------------------------------------
  # name             |object identifier
  # =================+=================================================
  # arp              |ipNetToPhysicalPhysAddress
  # -----------------+-------------------------------------------------
  # lldp (switches)  |1.0.8802.1.1.2.1.4.1.1.9
  # -----------------+-------------------------------------------------
  # ```
  def list_oids(list : NamedTuple)
    Util.clear_screen
    header = {"friendly name", "object identifier"}
    display_header("OIDs", header, "Included pre-defined object identifiers")
    display_formatted_table(list)
  end
end
