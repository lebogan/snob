# Displays the results of a snmpwalk operation.
module Reports

  # Displays the table information.
  def display_table_info(table)
    table.each do |label, info|
      printf("%-16s |%s\n", label.to_s, info.delete("\""))
      puts "-----------------+-------------------------------------------------"
    end
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
  #     Returns
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
      next if entry.size == 0# || entry == "00 \"" || entry.size == 1
      label = format_label(entry)
      info = truncate(entry.split(/=/)[1].strip).to_s
      table[label] = info
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
    pp oid
    pp header
    display_header(hostname, header, oid)
    display_table_info(table)
  end

  # Displays the raw unformatted snmpwalk results.
  def display_raw_table(table)
    table.to_s.split("\n").each { |line| puts line }
  end
end


