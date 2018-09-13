require "./spec_helper"
require "../src/snob/utils"
require "../src/snob/reports"

include Utils
include Reports

describe Reports do
  describe "#format_label " do
    entry = "ucdavis.7890.1.4.1.2.6.100.105.115.116.114.111.1 = Linux|3.10..."
    it "returns a string" do
      format_label(entry).should be_a(String)
      puts format_label(entry)
    end
  end
end
