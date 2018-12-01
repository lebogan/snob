require "./spec_helper"
require "../src/helpers"
require "../src/reports"

include Helpers
include Reports

describe Reports do
  describe "#format_label " do
    it "returns a distro string: " do
      entry = "ucdavis.7890.1.4.1.2.6.100.105.115.116.114.111.1 = Linux|3.10..."
      format_label(entry).should be_a(String)
      puts format_label(entry)
    end

    it "returns a lldp string: " do
      entry = "iso.0.8802.1.1.2.1.4.1.1.9.0.4.1"
      format_label(entry).should be_a(String)
      puts format_label(entry)
    end

    it "returns an arp string: " do
      entry = "ipNetToPhysicalPhysAddress.2.ipv4.\"0.0.0.0\""
      format_label(entry).should be_a(String)
      puts format_label(entry)
    end

    it "returns a hp_description string: " do
      entry = "enterprises.11.2.14.11.1.2.4.1.4.1"
      format_label(entry).should be_a(String)
      puts format_label(entry)
    end
  end

  describe "#format_table" do
    it "returns a Hash(String, String) " do
      table = {} of String => String
      results = "label=entry\none=1\n".split("\n")
      format_table(results, table).should be_a(Hash(String, String))
      puts table
    end
  end

  describe "#format_header" do
    it "returns a Tuple(String, String)" do
      format_header("1.0.8802.1.1.2.1.4.1.1.9").should be_a(Tuple(String, String))
    end
  end
end
