require "./spec_helper"
require "../src/snob/utils"

describe Utils do
  describe "run_cmd" do
    it "returns a Tuple(Int32, String)" do
      args = ("-ls").split(" ") # => Array of String
      status, result = Utils.run_cmd("ls", args)
      status.should be_a(Int32)
      result.should be_a(String)
    end
  end

  describe "truncate" do
    it "returns a string with 10 characters" do
      string = Utils.truncate("A truncated string ", 10).to_s
      string.size.should eq(10)
    end
  end
end
