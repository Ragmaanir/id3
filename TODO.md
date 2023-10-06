TODO
----

- 🟡 Notes on how to print mp3 tags using other tools:
  - `mid3v2 --list-raw spec/03.\ Kaste.mp3`
  - `mp3info spec/03.\ Kaste.mp3`
  - `exiftool -json spec/03.\ Kaste.mp3`
  - `ffprobe spec/03.\ Kaste.mp3`

- 🟡 Replace all inspect with pretty_print
- 🟡 Read apev2 tags (https://mutagen-specs.readthedocs.io/en/latest/apev2/)apev2.html
  - https://wiki.hydrogenaud.io/index.php?title=APEv1_specification
  - https://wiki.hydrogenaud.io/index.php?title=APEv2_specification
- 🟡 Calculate length of mp3 file (lazily)
  - http://www.mp3-tech.org/programmer/frame_header.html
  - https://www.codeproject.com/articles/8295/mpeg-audio-frame-header
  - https://shadowfacts.net/2021/mp3-duration/
  - http://mpgedit.org/mpgedit/mpeg_format/mpeghdr.htm
  - https://github.com/moumar/ruby-mp3info/blob/master/lib/mp3info.rb
- 🟡❓ Should TaggedFile shortcut genre return string or the V1 genre enum?
- 🟡🔒 Security: Validate sizes (configurable): max for tag is 256MB, max for frame is 16MB
- 🟡 Add more test files
- Checklist: https://stackoverflow.com/questions/63578757/id3-parser-and-editor

- 🟣 V2
  - 🟢 Read header
  - 🟢 Read text frames
  - 🟢 Cli command to print info and frames of a file
  - 🟢 Logging
  - 🟡 Read all V2 tags (2.2, 2.3, 2.4)
  - 🟡 Eager load most common frames, lazily load uncommon frames and frames with a lot of data
  - 🟡 Validate 3 character frame ids for 2.2
  - 🟡 Tag ids for 2.2 are different, so SHORTCUTS have to be different:
    title: TT2
    artist: TP1
    album: TAL
    year: TYE
    track: TRK
    comment: COM
    genre: TCO
  - 🟡 Better exceptions that show at which step or which frame an error occurred
  - 🟡 Strict and graceful mode: stop reading frames when there is an error, but dont raise
  - 🟡 Specs for 2.2/2.3
  - 🟡 Unicode
    - 🟡 Unicode strings must begin with the Unicode BOM
    - 🟡 Terminated strings are terminated with $00 00 if encoded as unicode
    - 🟡 Any empty Unicode strings which are NULL-terminated may have the Unicode BOM followed by a Unicode NULL
  - 🟡 Frames that allow different types of text encoding have a text encoding description byte directly after the frame size
  - 🟡 General Frame
    - 🟡 raw_flags
    - 🟡 raw_content / content
  - 🟡 Read common frames
    - 🟡 TCON with special encoding of id3v1 genres etc

- 🟣 V1
  - 🟢 Read title/artist etc
  - 🟢 Read genre
  - 🟡 Fast read method: only load V1 if no V2 tag exists or is incomplete?
    - Always leave reader in position after V2 tag

- 🧠
  - https://web.archive.org/web/20161022105303/http://id3.org/id3v2-chapters-1.0
  - https://mutagen-specs.readthedocs.io/en/latest/id3/id3v2.4.0-structure.html
  - ID3v2: https://gigamonkeys.com/book/practical-an-id3-parser.html

- 🏆🔔🚨🛑📌📍📂❗❓🚩💬🧠
- ⭐✅❌❎🔲⛔🚫☑️
- 🔴🟠🟡🟢🔵🟣🟤⚫⚪
- 🔒🔐🔑🛡
- 🛠🔧🐢🪲⚡💥🔥🩸🩹🪦
