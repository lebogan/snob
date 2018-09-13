# ===============================================================================
#         FILE:  reports.cr
#        USAGE:  Internal
#  DESCRIPTION:  Reporting utilities.
#       AUTHOR:  Lewis E. Bogan
#      COMPANY:  Earthsea@Home
#      CREATED:  2017-12-16 13:29
#    COPYRIGHT:  (C) 2017 Lewis E. Bogan <lewis.bogan@comcast.net>
# Distributed under terms of the MIT license.
# ===============================================================================

# Displays the results of a snmpwalk operation either raw or formatted.
FORMATTED_PAGE_SIZE = 15
RAW_PAGE_SIZE       = 30
SEPERATOR           = "-------------------+-------------------------------------------------"

module Reports
  # Displays the formatted table information, removes quotes from info string variable.
  def display_table_info(formatted_table : Hash | NamedTuple)
    page_count = 1
    formatted_table.each do |label, info|
      printf("%-18s |%s\n", label, info.delete("\""))
      puts SEPERATOR
      page_count += 1
      if page_count % FORMATTED_PAGE_SIZE == 0
        choice = ask_char("\n -- press any key to continue or q to quit --\n\n")
        choice == 'q' ? break : next
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
        choice = ask_char("\n -- press any key to continue or q to quit --\n\n ")
        choice == 'q' ? break : next
      end
    end
    puts "\n"
  end

  # Displays the report header.
  def display_header(hostname : String, header : Tuple, oid : String)
    print_chars('=', 67)
    puts "#{hostname.upcase} - #{oid}"
    print_chars('-', 67)
    printf("%-18s | %s\n", header[0], header[1])
    print_chars('=', 67)
  end

  # Formats the label depending on which oid it represents.
  def format_label(entry : String) : String
    label = entry.split(/=/)[0].split(/\"/)
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

  # Formats the table into label and info.
  def format_table(results : Array, table : Hash) : Hash(String, String)
    results.each do |entry|
      if entry.split(/=/).size > 1
        label = format_label(entry)
        info = truncate(entry.split(/=/)[1]).to_s
        table[label] = info
      end
    end
    table # => Hash(String, String)
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
    display_table_info(formatted_table)
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
    clear_screen
    header = {"friendly name", "object identifier"}
    display_header("OIDs", header, "Included pre-defined object identifiers")
    display_table_info(list)
  end
end
