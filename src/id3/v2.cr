require "./v2/header"
require "./v2/frames"

module Id3::V2
  Log = ::Log.for(self)

  IDENTIFIER = "ID3"

  record(Version, major : UInt8, minor : UInt8) do
    def initialize(@major, @minor)
      raise "Invalid major version: #{major}" unless major.in?(2, 3, 4)
    end

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

    # SPEC 2.3: The tag size is the size of the complete tag after
    # unsychronisation, including padding, excluding the header but
    # not excluding the extended header (total tag size - 10)

    # # SPEC 2.4:
    # # The ID3v2 tag size is the sum of the byte length of the extended
    # # header, the padding and the frames after unsynchronisation.
    # frames_end_pos = r.pos.to_i64 + (header.tag_size - ext_size)
    # frames = Frame.read_all(r, frames_end_pos, header)

    # https://hydrogenaud.io/index.php/topic,71966.0.html

    body = r.read(header.tag_size)

    if header.version.major < 4 && header.flags.unsynchronization?
      body = UnsynchronizationScheme.unapply(body)
    end

    rr = Reader.new(body)

    if header.flags.extended_header?
      ext_size = peek_extended_header_size(rr, header)

      # skip over extended header
      rr.move(ext_size)
    end

    frames = Frame.read_all(rr, header)

    Log.trace &.emit("read completed", frames: frames.size)

    Tag.new(header, frames)
  end

  def self.peek_extended_header_size(r : Reader, header : Header)
    size = r.read_int32
    r.move(-4)

    ext_size = if header.version.major == 3
                 # 2.3.0: size does not include size field itself, so we add it
                 size + 4
               else
                 SynchsafeInt.decode(size)
               end

    Log.trace &.emit("extended header size", size: ext_size)

    ext_size
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
