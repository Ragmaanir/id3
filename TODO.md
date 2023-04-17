TODO
----

- 🟡❓ Should TaggedFile shortcut genre return string or the V1 genre enum?
- 🟡🔒 Security: Validate sizes (configurable): max for tag is 256MB, max for frame is 16MB
- 🟡 Add more test files

- 🟣 V2
  - 🟢 Read header
  - 🟢 Read text frames
  - 🟢 Cli command to print info and frames of a file
  - 🟢 Logging
  - 🟡 Eager load most common frames, lazily load uncommon frames and frames with a lot of data
  - 🟡 Validate 3 character frame ids for 2.2
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

- 🧠
  - https://web.archive.org/web/20161022105303/http://id3.org/id3v2-chapters-1.0
  - https://mutagen-specs.readthedocs.io/en/latest/id3/id3v2.4.0-structure.html
  - ID3v2: https://gigamonkeys.com/book/practical-an-id3-parser.html

- 🏆🔔🚨🛑📌📍📂❗❓🚩💬🧠
- ⭐✅❌❎🔲⛔🚫☑️
- 🔴🟠🟡🟢🔵🟣🟤⚫⚪
- 🔒🔐🔑🛡
- 🛠🔧🐢🪲⚡💥🔥🩸🩹🪦
