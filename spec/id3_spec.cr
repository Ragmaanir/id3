require "./spec_helper"

describe Id3 do
  include Id3
  include Id3::V2

  def test_file
    Reader.new(File.new("./spec/v2.mp3"))
  end

  test "V2Header.read" do
    h = V2::Header.read(test_file)

    assert h.version == V2::Header::Version.new(0x3, 0x0)
    assert h.flags.none?
    assert h.tag_size == 1193
  end

  test "Id3.read" do
    data = Id3.read(test_file)

    assert data.class == Tag

    tag = data.as(Tag)

    assert tag.header.version == V2::Header::Version.new(0x3, 0x0)
    assert tag.header.flags == V2::Header::Flags::None
    assert tag.frames.size == 7

    frames = [
      TextFrame.new("TIT2", Bytes[0, 0], :ISO8859_1, "The Title Of This Dummy File"),
      TextFrame.new("TPE1", Bytes[0, 0], :ISO8859_1, "Another Artist"),
      TextFrame.new("TALB", Bytes[0, 0], :ISO8859_1, "Trees in the Forest"),
      Frame.new("COMM", "\u0000eng\u0000The Comment".to_slice, Bytes[0, 0], tag.header.version),
      TextFrame.new("TRCK", Bytes[0, 0], :ISO8859_1, "1"),
      TextFrame.new("TYER", Bytes[0, 0], :ISO8859_1, "2023"),
      TextFrame.new("TCON", Bytes[0, 0], :ISO8859_1, "Black Metal"),
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
