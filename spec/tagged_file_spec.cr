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

  test "multiple chapters" do
    data = TaggedFile.read(Path["./spec/chapters.mp3"])

    t = data.v2.not_nil!

    assert t.all("CHAP").size == 129
  end

  test "rare frames" do
    data = TaggedFile.read(Path["./spec/rare_frames.mp3"])

    t = data.v2.not_nil!

    assert t.frames.map(&.id) == [
      "COMM", "TXXX", "TXXX", "TCON", "WXXX", "WXXX", "UFID",
    ]

    assert t.all("TXXX").size == 2
    udf = t.first("TXXX").as(V2::UserDefinedTextFrame)
    assert udf.description == "userTextDescription1"
    assert udf.value == "userTextData1"
    # TODO: there is hidden text: "userTextDescription1\u0000userTextData1\u0000userTextData2"
  end

  test "unsynch" do
    data = TaggedFile.read(Path["./spec/unsynch.mp3"])

    t = data.v2.not_nil!

    assert t.title == "My babe just cares for me"
    assert t.artist == "Nina Simone"
    assert t.album == "100% Jazz"
    assert t.track == "03"
    assert t.first("TLEN").as(V2::TextFrame).content == "216000"
  end
end
