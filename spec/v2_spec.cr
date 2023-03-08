require "./spec_helper"

describe Id3::V2 do
  include Id3
  include Id3::V2

  test "Header.read" do
    h = Header.read(v2_reader)

    assert h.version == Version.new(0x3, 0x0)
    assert h.flags.none?
    assert h.tag_size == 1193
  end

  test "read" do
    data = V2.read(v2_reader)

    assert data.class == Tag

    tag = data.as(Tag)

    assert tag.header.version == Version.new(0x3, 0x0)
    assert tag.header.flags == Header::Flags::None
    assert tag.frames.size == 7

    v = tag.header.version
    sf = Frame::StatusFlags::None
    ff = Frame::FormatFlags::None

    frames = [
      TextFrame.new("TIT2", v, sf, ff, :ISO8859_1, "The Title Of This Dummy File"),
      TextFrame.new("TPE1", v, sf, ff, :ISO8859_1, "Another Artist"),
      TextFrame.new("TALB", v, sf, ff, :ISO8859_1, "Trees in the Forest"),
      Frame.new("COMM", v, sf, ff, "\u0000eng\u0000The Comment".to_slice),
      TextFrame.new("TRCK", v, sf, ff, :ISO8859_1, "1"),
      TextFrame.new("TYER", v, sf, ff, :ISO8859_1, "2023"),
      TextFrame.new("TCON", v, sf, ff, :ISO8859_1, "Black Metal"),
    ]

    assert tag.frames == frames

    assert tag.title == "The Title Of This Dummy File"
    assert tag.artist == "Another Artist"
    assert tag.album == "Trees in the Forest"
    assert tag.track == "1"
    assert tag.year == "2023"
    assert tag.genre == "Black Metal"
  end
end
