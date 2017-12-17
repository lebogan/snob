module Snob
  VERSION = begin
              YAML.parse(File.read(File.join(__DIR__, "../..",
                                             "shard.yml")))["version"].as_s
            end
end
