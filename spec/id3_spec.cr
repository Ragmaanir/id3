require "./spec_helper"

describe Id3 do
  def test_file
    Id3::Reader.new(File.new("./spec/a.mp3"))
  end

  test "V2Header.read" do
    h = Id3::V2::Header.read(test_file)

    assert h.version == Id3::V2::Header::Version.new(0x3, 0x0)
    assert h.flags.none?
    assert h.tag_size == 1193
  end

  test "Id3.read" do
    m = Id3.read(test_file)

    p m
  end
end
