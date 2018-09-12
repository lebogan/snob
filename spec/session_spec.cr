require "./spec_helper"
require "../src/snob/session.cr"
require "secrets"

describe Session do
  describe "#configure_session" do
    it "returns a Tuple(Hash(String, String))" do
      puts "\nConfiguring a test session ..."
      config = Session.configure_session
      config.should be_a(Tuple(Hash(String, String)))
    end
  end
end
