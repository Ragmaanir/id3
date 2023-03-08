require "./v2/header"
require "./v2/frames"

module Id3::V2
  IDENTIFIER = "ID3"

  record(Version, major : UInt8, minor : UInt8)

  def self.present?(r : Reader)
    if r.size > Header::SIZE
      id = r.peek_string(3)

      id == IDENTIFIER
    end
  end

  def self.read(r : Reader)
    header = Header.read(r)
    ext_size = read_extended_header_size(r, header)

    # skip over extended header
    r.seek(Header::SIZE + ext_size)

    remaining = header.tag_size - ext_size

    body = r.read(remaining)

    frames = Frame.read_all(Reader.new(body), header.version)

    Tag.new(header, frames)
  end

  def self.read_extended_header_size(r : Reader, header : Header)
    if header.flags.extended_header?
      size = r.read_int32

      if header.version.major == 3
        # 2.3.0: size does not include size field itself, so we add it
        size + 4
      else
        SynchsafeInt.decode(size)
      end
    else
      0
    end
  end

  class Tag
    getter header : Header
    getter frames : Array(Frame)
    @by_id : Hash(String, Frame)

    def initialize(@header, @frames)
      @by_id = frames.to_h { |f| {f.id, f} }
    end

    SHORTCUTS = {
      "TIT2" => :title,
      "TPE1" => :artist,
      "TALB" => :album,
      "TRCK" => :track,
      "TYER" => :year,
      "TCON" => :genre,
    }

    {% for id, name in SHORTCUTS %}
      def {{name.id}}
        @by_id[{{id}}]?.try(&.as(TextFrame).content)
      end
    {% end %}
  end
end
