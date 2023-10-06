require "../spec_helper"

describe Mp3::Meta do
  include Mp3

  test "read" do
    r = Id3::Reader.new(File.new("./spec/Ragmaanir - Crystal.mp3"))
    m = Meta.read(r, fast: false)

    assert m.approximate_duration == Time::Span.new(seconds: 27, nanoseconds: 507_257_856)
    assert m.duration == Time::Span.new(seconds: 27, nanoseconds: 455_012_352)

    assert m.approximate_frame_count == 1053
    assert m.frame_count == 1051
  end
end
