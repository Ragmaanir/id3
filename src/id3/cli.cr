require "../id3"
require "./cli/readme"
require "./cli/inspect"

# require "./cli/release"

module Id3
  module Cli
    def self.run(argv = ARGV)
      root = Kommando::Namespace.root do
        command Readme
        command Inspect
        # command Release
      end

      root.exec(argv)
    end
  end
end

Id3::Cli.run
