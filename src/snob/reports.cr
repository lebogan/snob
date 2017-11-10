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
  def display_header(hostname, header)
    puts "==================================================================="
    puts "#{hostname.upcase} - #{header[2]}"
    puts "-------------------------------------------------------------------"
    printf("%-16s |%s\n", header[0], header[1])
    puts "=================+================================================="
  end

  # Formats the table into label and info.
  #     Returns # => Hash(String, String)
  def format_table(results, table)
    results.each do |entry|
      next if entry == "" || entry == "00 \"" || entry.size == 1
      info = truncate(entry.split(/=/)[1].strip).to_s
      label = entry.split(/=/)[0].split(/\./)[-2]
      table[label] = info
    end
    table
  end

  # Displays header and formatted table information.
  def display_table(table, hostname, oid)
    header = {"key", "value", "#{oid}"} # => Tuple(String, String, String)
    display_header(hostname, header)
    display_table_info(table)
  end

  # Displays the raw unformatted snmpwalk results.
  def display_stuff(table)
    table.to_s.split("\n").each { |line| puts line }
  end
end


