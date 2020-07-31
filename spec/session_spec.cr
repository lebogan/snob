require "./spec_helper"
require "../src/session.cr"
require "secrets"

describe Session do
  describe "#configure_session" do
    it "returns a Tuple(Hash(String, String))" do
      puts "\nConfiguring a test session ..."
      config = Session.configure_session
      puts typeof(config)
      config.should be_a(NamedTuple(user: String, auth_pass: String, priv_pass: String, auth: String, crypto: String))
    end
  end
end
