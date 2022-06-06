# ===============================================================================
#         FILE:  snob.cr
#        USAGE:  snob [arguments...]
#  DEVELOPMENT:  crystal build|run src/snob.cr --warnings all --error-on-warnings
#      RELEASE:  crystal build --release src/snob.cr
#  DESCRIPTION:  A simple Snmp Network Object Browser.
#      OPTIONS:  ---
# REQUIREMENTS:  snmp snmp-mib-downloader
#         BUGS:  ---
#        NOTES:
#       AUTHOR:  Lewis E. Bogan
#      COMPANY:  Earthsea@Home
#      CREATED:  2017-11-10 10:19
#    COPYRIGHT:  (C) 2017-2021 Lewis E. Bogan <lewis.bogan@comcast.net>
#    GIT REPOS:  earthforge, GitHub
#             :  git remote add origin git@earthforge.earthsea.local:lewisb/snob.git
#             :  git remote set-url --add --push origin git@github.com:lebogan/snob.git
#             :  git push -u origin master
# Distributed under terms of the MIT license.
# ===============================================================================

require "yaml"
require "option_parser"
require "socket"
require "term-prompt"
require "./cli"

OIDLIST = {arp:     "ipNetToPhysicalPhysAddress",
           lldp:    "1.0.8802.1.1.2.1.4.1.1.9",
           sys:     "system",
           mem:     "memory",
           dsk:     "dskTable",
           ifdesc:  "ifDescr",
           distro:  "ucdavis.7890.1.4",
           temp:    "lmTempSensorsDevice",
           hp_desc: "enterprises.11.2.14.11.1.2.4.1.4.1",
} # => NamedTuple(Symbol, String...)

CONFIG_PATH = File.expand_path("#{ENV["HOME"]}/.snob")
CONFIG_FILE = File.expand_path("#{CONFIG_PATH}/snobrc.yml")
OUT_PATH    = File.expand_path("#{ENV["HOME"]}/tmp")
OUT_FILE    = File.expand_path("#{OUT_PATH}/raw_dump.txt")
VERSION     = {{ `shards version #{__DIR__}`.chomp.downcase.stringify }}
PROMPT      = Term::Prompt.new

# Allows displaying object methods during development.
class Object
  macro methods
    {{ @type.methods.map &.name.stringify }}
  end
end

App.run
