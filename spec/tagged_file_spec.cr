require "./spec_helper"

describe Id3 do
  include Id3

  test "read v1 only" do
    t = TaggedFile.read(v1_reader)

    assert t.v1
    assert !t.v2

    assert t.title == "The Title Of This Dummy File"
    assert t.artist == "Another Artist"
    assert t.album == "Trees in the Forest"
    assert t.track == "1"
    assert t.year == "2023"
    # assert t.genre == "Black Metal"
    assert t.genre == V1::Genre::BlackMetal
  end

  test "read v2 only" do
    t = TaggedFile.read(v2_reader)

    assert !t.v1
    assert t.v2

    assert t.title == "The Title Of This Dummy File"
    assert t.artist == "Another Artist"
    assert t.album == "Trees in the Forest"
    assert t.track == "1"
    assert t.year == "2023"
    assert t.genre == "Black Metal"
  end

  test "read both v1 and v2"
end
