require "./spec_helper"
require "../src/helpers"
require "socket"

include Helpers

describe Helpers do
  describe "#resolve_host" do
    it "returns a Socket object" do
      resolve_host("example.com").should be_a(Socket::IPAddress)
    end

    it "returns a string" do
      resolve_host("example.com").to_s.rstrip(":7").should be_a(String)
    end
  end
end
