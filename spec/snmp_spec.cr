require "./spec_helper"
require "../src/snob/snmp"

describe Snmp do
  describe "#initialize" do
    it "creates a new Snmp object." do
      host_session = Snmp::Snmp.new("auth", "priv", "test_user", "crypto")
      host_session.should be_a(Snmp::Snmp)
    end
  end

  describe "walk_mib3" do
    it "attempts to walk the mib tree branch" do
      host_session = Snmp::Snmp.new("auth", "priv", "test_user", "crypto")
      host_session.walk_mib3("myhost", "system", "Qv").should be_a(Tuple(Int32, String))
    end
  end
end
