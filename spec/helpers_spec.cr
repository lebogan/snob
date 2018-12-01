require "./spec_helper"
require "../src/helpers"
require "../src/messages"

include Helpers
include Messages

TEST_ARGV = ["test"]
BLANK_ARGV = [] of String

describe Helpers do
  describe "#process_argv" do
    it "returns a string when ARGV is given" do
      process_argv(TEST_ARGV).should be_a(String)
    end
  end

  describe "#process_argv" do
    it "prompts for a string when no ARGV is given\n" do
      process_argv(BLANK_ARGV).should be_a(String)
    end
  end

  describe "#print_chars(character, number)" do
    it "prints a number of specified characters and returns nil" do
      print_chars('*', 10).should be_nil
    end
  end

  describe "#print_chars" do
    it "prints 20 dashes by default and returns nil" do
      print_chars.should be_nil
    end
  end
end
