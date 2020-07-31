require "./spec_helper"
require "../src/snmp"

host_session = Snmp::Snmp.new("auth_pass", "priv_pass", "test_user",
  "auth", "crypto")

describe Snmp do
  describe "#initialize" do
    it "returns a new Snmp session object" do
      host_session.should be_a(Snmp::Snmp)
    end
  end

  describe "walk_mib3" do
    it "returns a Tuple(Int32, String)" do
      host_session.walk_mib3("myhost", "system", "Qv").should be_a(Tuple(Int32, String))
    end
  end
end
