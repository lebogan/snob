require "./spec_helper"
require "yaml"
require "myutils"
require "../src/config"

CONFIG_PATH = File.expand_path("#{ENV["HOME"]}/.snob")
CONFIG_FILE = File.expand_path("#{CONFIG_PATH}/snobrc.yml")

include Config

describe Config do
  describe "#check_for_config" do
    it "builds a config file in the home directory" do
      Config.check_for_config(CONFIG_PATH, CONFIG_FILE)
      File.exists?(CONFIG_FILE).should be_true
    end
  end
end
