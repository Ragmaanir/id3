r = Reader.new(Path["spec/Ragmaanir - Crystal.mp3"])
m = Meta.read(r, fast: false)

m.tags        # access id3 v1 and v2
m.xing_header # access xing header

assert m.approximate_duration == Time::Span.new(seconds: 27, nanoseconds: 507_257_856)
assert m.duration == Time::Span.new(seconds: 27, nanoseconds: 455_012_352)

assert m.approximate_frame_count == 1053
assert m.frame_count == 1051
