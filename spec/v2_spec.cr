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
    flags = Frame::NewFlags.new(:none, :none)

    frames = [
      TextFrame.create("TIT2", v, 29, flags, :ISO8859_1, "The Title Of This Dummy File"),
      TextFrame.create("TPE1", v, 15, flags, :ISO8859_1, "Another Artist"),
      TextFrame.create("TALB", v, 20, flags, :ISO8859_1, "Trees in the Forest"),
      CommentFrame.create("COMM", v, 16, flags, :ISO8859_1, "eng", "", "The Comment".to_slice),
      TextFrame.create("TRCK", v, 2, flags, :ISO8859_1, "1"),
      TextFrame.create("TYER", v, 5, flags, :ISO8859_1, "2023"),
      TextFrame.create("TCON", v, 12, flags, :ISO8859_1, "Black Metal"),
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
