require "./spec_helper"

describe Id3::V1 do
  include Id3
  include Id3::V1

  test "present?" do
    assert V1.present?(v1_reader)
  end

  test "read" do
    data = V1.read(v1_reader)

    assert data.class == Tag

    tag = data.as(Tag)

    assert tag.title == "The Title Of This Dummy File"
    assert tag.artist == "Another Artist"
    assert tag.album == "Trees in the Forest"
    assert tag.track == "1"
    assert tag.year == "2023"
    assert tag.genre == Genre::BlackMetal
  end

  test "when fields empty" do
    r = Id3::Reader.new(File.new("./spec/v1_missing.mp3"))
    data = V1.read(r)

    tag = data.as(Tag)

    assert tag.title == nil
    assert tag.artist == nil
    assert tag.album == nil
    assert tag.year == nil
    assert tag.comment == nil
    assert tag.track == "1"
    assert tag.genre == nil
  end
end
