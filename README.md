# Id3 [![Crystal CI](https://github.com/Ragmaanir/id3/actions/workflows/crystal.yml/badge.svg)](https://github.com/Ragmaanir/id3/actions/workflows/crystal.yml)

### Version 0.1.2

ID3 reader library written in pure crystal.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     id3:
       github: ragmaanir/id3
   ```

2. Run `shards install`

## Usage

```crystal
require "id3"
```

```crystal
r = Reader.new(Path["spec/Ragmaanir - Crystal.mp3"])
m = Meta.read(r, fast: false)

m.tags        # access id3 v1 and v2
m.xing_header # access xing header

assert m.approximate_duration == Time::Span.new(seconds: 27, nanoseconds: 507_257_856)
assert m.duration == Time::Span.new(seconds: 27, nanoseconds: 455_012_352)

assert m.approximate_frame_count == 1053
assert m.frame_count == 1051

```

```crystal
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

```


## Features

- 🟢 Read basic v1 and v2 tag information (title, artist, album, track, year, genre)
- 🟢 Read unsynchronized frames
- 🟢 Calculate mp3 length using Xing header or by counting the frames in the file

Use `./cli` for these tasks:

```bash
./cli

Commands:

  readme          Generate README.md from README.md.ecr
  inspect         Print ID3 metadata of a mp3 file
  frames          Print metadata of the file, like approximate duration, exact duration, frames, ...


```

## Contributing

1. Fork it (<https://github.com/ragmaanir/id3/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

When changing the `README.md`, change `README.md.ecr` instead and run `./cli readme` to generate `README.md`.

## Contributors

- [Ragmaanir](https://github.com/ragmaanir) - creator and maintainer
