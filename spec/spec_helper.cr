require "microtest"
require "../src/id3"

include Microtest::DSL

def v1_file
  File.new("./spec/v1.mp3")
end

def v1_reader
  Id3::Reader.new(v1_file)
end

def v2_file
  File.new("./spec/v2.mp3")
end

def v2_reader
  Id3::Reader.new(v2_file)
end

Microtest.run!
