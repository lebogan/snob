require "./spec_helper"
require "../src/snob/utils"

describe Utils do
  describe "run_cmd" do
    it "returns a Tuple(Int32, String)" do
      args = ("-ls").split(" ") # => Array of String
      status, result = Utils.run_cmd("ls", args)
      status.should eq 0
      result.should be_a(String)
    end
  end

  describe "configure_session" do
    it "returns a Hash(Symbol, String)" do
      config = Utils.configure_session[0].to_h # => Hash(String, String)
      config.should be_a(Hash(String, String))
    end
  end

  describe "truncate" do
    it "returns a string with 10 characters" do
      string = Utils.truncate("A truncated string ", 10).to_s
      pp string
      string.size.should eq(10)
    end
  end
end
