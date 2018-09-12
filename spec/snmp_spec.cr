require "./spec_helper"
require "../src/snob/snmp"

describe Snmp do
  describe "#initialize" do
    it "creates a new Snmp object." do
      host = Snmp::Snmp.new("auth", "priv", "test_user", "crypto")
      host.should be_a(Snmp::Snmp)
    end
  end
end
