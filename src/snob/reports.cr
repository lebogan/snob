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
module Reports

  # Displays the table information.
  def display_table_info(formatted_table : Hash | NamedTuple)
    page_size = 15
    page_count = 1
    formatted_table.each do |label, info|
      printf("%-16s |%s\n", label, info.delete("\""))
      puts "-----------------+-------------------------------------------------"
      page_count += 1
      if page_count % page_size == 0
        choice = ask_char("\n -- press any key to continue or q to quit --  ")
        choice == 'q' ? break : next
      end
    end
    puts "\n\n"
  end

  # Displays the report header.
  def display_header(hostname : String, header : Tuple, oid : String)
    puts "==================================================================="
    puts "#{hostname.upcase} - #{oid}"
    puts "-------------------------------------------------------------------"
    printf("%-16s |%s\n", header[0], header[1])
    puts "=================+================================================="
  end

  # Formats the label depending on which oid it represents.
  def format_label(entry : String) : String
    case
    when entry.split(/=/)[0].split(/\"/)[0].includes?("ipNetToPhysicalPhysAddress")
      label = entry.split(/=/)[0].split(/\"/)[-2].to_s
    when entry.split(/=/)[0].split(/\"/)[0].includes?("iso")
      label = entry.split(/=/)[0].split(/\"/)[0].split(/\./)[-2..-1].join(".").to_s
    else
      label = entry.split(/=/)[0].split(/\"/)[0].to_s
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
      {"oid", "description"}
    end
  end

  # Displays header and formatted table information.
  def display_table(formatted_table : Hash, hostname : String, oid : String)
    header = format_header(oid) # => Tuple(String, String, String)
    display_header(hostname, header, oid)
    display_table_info(formatted_table)
  end

  # Displays the raw unformatted snmpwalk results.
  def display_raw_table(table : Array(String))
    page_size = 30
    page_count = 1
    table.each do |line|
      puts line
      page_count += 1
      if page_count % page_size == 0
        choice = ask_char("\n -- press any key to continue or q to quit --  ")
        choice == 'q' ? break : next
      end
    end
    puts "\n\n"
  end

  # Lists some useful difficult-to-remember oids.
  #
  #```text
  #===================================================================
  #OIDS - Included pre-defined object identifiers
  #-------------------------------------------------------------------
  #name             |object identifier
  #=================+=================================================
  #arp              |ipNetToPhysicalPhysAddress
  #-----------------+-------------------------------------------------
  #lldp             |1.0.8802.1.1.2.1.4.1.1.9
  #-----------------+-------------------------------------------------
  #```
  def list_oids(list : NamedTuple)
    clear_screen
    header = {"name", "object identifier"}
    display_header("OIDs", header, "Included pre-defined object identifiers")
    display_table_info(list)
  end
end
