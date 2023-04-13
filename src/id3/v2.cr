require "./v2/header"
require "./v2/frames"

module Id3::V2
  Log = ::Log.for(self)

  IDENTIFIER = "ID3"

  record(Version, major : UInt8, minor : UInt8) do
    def inspect(io)
      io << "Version("
      io << major
      io << ", "
      io << minor
      io << ")"
    end
  end

  def self.present?(r : Reader)
    if r.size > Header::SIZE
      id = r.peek_string(3)

      id == IDENTIFIER
    end
  end

  def self.read(r : Reader)
    Log.trace &.emit("read", at: r.pos)

    header = Header.read(r)
    ext_size = read_extended_header_size(r, header)

    # skip over extended header
    r.move(ext_size)

    remaining = header.tag_size - ext_size

    body = r.read(remaining)
    body = UnsynchronizationScheme.unapply(body) if header.flags.unsynchronization?
    frames = Frame.read_all(Reader.new(body), header.version)

    Log.trace &.emit("read completed", frames: frames.size)

    Tag.new(header, frames)
  end

  def self.read_extended_header_size(r : Reader, header : Header)
    if header.flags.extended_header?
      size = r.read_int32

      ext_size = if header.version.major == 3
                   # 2.3.0: size does not include size field itself, so we add it
                   size + 4
                 else
                   SynchsafeInt.decode(size)
                 end

      Log.trace &.emit("extended header size", size: ext_size)

      ext_size
    else
      0
    end
  end

  class Tag
    getter header : Header
    getter frames : Array(Frame)

    def initialize(@header, @frames)
    end

    def first?(id : String) : Frame?
      @frames.find { |f| f.id == id }
    end

    def first(id : String) : Frame
      first?(id).not_nil!
    end

    def all(id : String) : Array(Frame)
      @frames.select { |f| f.id == id }
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
      @__frame__{{name.id}} : Frame?

      def {{name.id}}
        @__frame__{{name.id}} ||= first?({{id}})
        @__frame__{{name.id}}.try(&.as(TextFrame).content)
      end
    {% end %}

    def inspect(io)
      io << "V2::Tag("
      header.inspect(io)
      io << ", "
      frames.inspect(io)
      io << ")"
    end
  end
end
