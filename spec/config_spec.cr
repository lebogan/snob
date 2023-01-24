require "./spec_helper"
require "yaml"
require "../src/config"
require "../src/reports"

CONFIG_PATH = File.expand_path("#{ENV["HOME"]}/.snob")
CONFIG_FILE = File.expand_path("#{CONFIG_PATH}/snobrc.yml")

include Config
# include Reports

describe Config do
  describe "#build_default_config" do
    it "builds a default config file in the home directory" do
      Config.build_default_config(CONFIG_PATH, CONFIG_FILE) unless File.exists?(CONFIG_FILE)
      File.exists?(CONFIG_FILE).should be_true
    end
  end

  describe "#fetch_credentials" do
    it "returns a NamedTuple object" do
      config = fetch_credentials(CONFIG_FILE, "dummy")
      config.should be_a(NamedTuple(user: String, auth_pass: String, priv_pass: String,
        auth: String, crypto: String))
      puts config.class
    end
  end

  describe "#update_config_file" do
    pending "updates the config file" do
      update_config_file("test_host")
      config = fetch_credentials(CONFIG_FILE, "test_host")
      config["test_host"]["user"].should be_a(String)
    end
  end
end
