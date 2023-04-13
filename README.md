# id3

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

t = Id3::TaggedFile.read(Path["file.mp3"])

assert t.title == "The Title Of This Dummy File"
assert t.artist == "Another Artist"
assert t.album == "Trees in the Forest"
assert t.track == "1"
assert t.year == "2023"
assert t.genre == "Black Metal"


v2 = t.v2.not_nil!

v2.frames # access frames of v2
v2.first("TLEN").as(Id3::V2::TextFrame).content # content of first TLEN frame
```

## Features

- 🟢 Read basic v1 and v2 tag information (title, artist, album, track, year, genre)
- 🟢 Read unsynchronized frames
- 🟡 Parse compressed/encrypted frames
- 🟡 Parse extended header

## Contributing

1. Fork it (<https://github.com/ragmaanir/id3/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Ragmaanir](https://github.com/ragmaanir) - creator and maintainer
