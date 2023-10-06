require "colorize"
require "kommando"

class Id3::Cli::Frames
  include Kommando::Command

  def self.description
    "Print metadata of the file, like approximate duration, exact duration, frames, ..."
  end

  arg :file, String

  def call
    r = Reader.new(Path[file])

    puts Mp3::Meta.read(r, fast: false)
  end
end
