require "./spec_helper"
require "../src/snob/session.cr"

describe Session do
  describe "configure_session" do
    it "returns a Hash(String, String)" do
      puts "Configuring a test session ..."
      config = Session.configure_session[0].to_h # => Hash(String, String)
      config.should be_a(Hash(String, String))
    end
  end
end
