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

# Displays the results of a snmpwalk operation.
module Reports
  # Displays the table information.
  def display_table_info(table)
    page_size = 15
    page_count = 1
    table.each do |label, info|
      printf("%-16s |%s\n", label, info.delete("\""))
      puts "-----------------+-------------------------------------------------"
      page_count += 1
      if page_count % page_size == 0
        choice = page("\n -- press any key to continue or q to quit -- \n\n")
        choice == 'q' ? break : next
      end
    end
    puts "\n\n"
  end

  # Displays the report header
  def display_header(hostname, header, oid)
    puts "==================================================================="
    puts "#{hostname.upcase} - #{oid}"
    puts "-------------------------------------------------------------------"
    printf("%-16s |%s\n", header[0], header[1])
    puts "=================+================================================="
  end

  # Formats the label depending on which oid it represents.
  #     Returns # => String
  def format_label(entry)
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
  #     Returns # => Hash(String, String)
  def format_table(results, table)
    results.each do |entry|
      if entry.split(/=/).size > 1
        label = format_label(entry)
        info = truncate(entry.split(/=/)[1]).to_s
        table[label] = info
      end
    end
    table
  end

  # Formats the appropriate oid header.
  #     Returns  # => Tuple(String, String)
  def format_header(oid)
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
  def display_table(table, hostname, oid)
    header = format_header(oid) # => Tuple(String, String, String)
    display_header(hostname, header, oid)
    display_table_info(table)
  end

  # Displays the raw unformatted snmpwalk results.
  def display_raw_table(table)
    page_size = 20
    page_count = 1
    table.each do |line|
      puts line
      page_count += 1
      if page_count % page_size == 0
        choice = page("\n -- press any key to continue or q to quit -- \n\n")
        choice == 'q' ? break : next
      end
    end
    puts "\n\n"
  end

  # Lists some useful oids.
  def list_oids(list)
    clear_screen
    header = {"flag name", "oid name"}
    display_header("OIDs", header, "Included pre-defined flag names")
    display_table_info(list)
  end

  # Opens a file for writing. Creates it if it doesn't exist. Overwrites contets.
  def write_raw_results_to_file(filename, content)
    File.open(filename, "w") do |file|
      file.puts content
    end
  end
end
