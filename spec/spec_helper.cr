require "microtest"
require "../src/id3"

# require "taglib"

# Log.setup(:trace)

include Microtest::DSL

def v1_reader
  Id3::Reader.new(File.new("./spec/v1.mp3"))
end

def v2_reader
  Id3::Reader.new(File.new("./spec/v2.mp3"))
end

Microtest.run!
