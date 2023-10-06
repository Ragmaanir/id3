t = Id3::TaggedFile.read(Path["spec/Ragmaanir - Crystal.mp3"])

assert t.title == "Crystal"
assert t.artist == "Ragmaanir"
assert t.album == "None"
assert t.track == "1"
assert t.year == "2023"
assert t.genre == "Black Metal"
assert t.comment == "Created with LMMS"

v2 = t.v2.not_nil!

assert v2.title == "Crystal"
assert v2.artist == "Ragmaanir"
assert v2.album == "None"
assert v2.track == "1"
assert v2.year == "2023"
assert v2.genre == "Black Metal"
assert v2.comment == "Created with LMMS"

# access frames of v2
assert v2.frames.size == 9

# access TLEN frame
len = v2.first("TLEN").as(Id3::V2::TextFrame)

assert len.content == "100" # content of first TLEN frame
