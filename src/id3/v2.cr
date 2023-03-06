require "./v2/header"
require "./v2/frames"

module Id3::V2
  IDENTIFIER = "ID3"

  def self.read(r : Reader)
    header = Header.read(r)
    ext_size = read_extended_header_size(r, header)

    r.seek(Header::SIZE + ext_size)

    remaining = header.tag_size - ext_size

    body = r.read(remaining)

    frames = read_frames(Reader.new(body), header)

    Tag.new(header, frames)
  end

  def self.read_extended_header_size(r : Reader, header : Header)
    if header.flags.extended_header?
      size = r.read_int32

      if header.version.major == 3
        # ext. header size for 2.3.0 does not include size bytes.
        # There are only 2 possible sizes - 6 or 10 bytes, which means extended header can take 10 or 14 bytes.
        size + 4
      else
        SynchsafeInt.decode(size)
      end
    else
      0
    end
  end

  def self.read_frames(r : Reader, header)
    frames = [] of Frame

    loop do
      frames << read_frame(r, header)

      b = r.peek_byte
      break if b == nil || b == 0 # eof or padding
    end

    frames
  end

  def self.read_frame(r : IO, header : Header)
    major = header.version.major

    id_length = major <= 2 ? 3 : 4

    # id = r.read(id_length)
    id = r.read_string(id_length)

    size = case major
           when 4
             SynchsafeInt.decode(r.read_int32)
           when 3
             r.read_int32
           when 2
             bytes = Bytes[0x0, 0x0, 0x0, 0x0]
             r.read(bytes[1, 3]) == 3 || raise("Unexpected EOF")
             IO::ByteFormat::BigEndian.decode(Int32, bytes)
           else raise("Invalid major version: #{major}")
           end

    has_flags = major > 2
    flags = has_flags ? r.read(2) : nil
    content = r.read(size)

    frame_class(id).new(
      id,
      content,
      flags,
      header.version
    )
  end

  def self.frame_class(id : String)
    case id
    when /^T/
      TextFrame
    else
      Frame
    end
  end

  # def self.frame_class(id : String)
  #   case id
  #   when /^(TCON|TCO)$/
  #     GenreFrame
  #   when /^TXX/
  #     UserTextFrame
  #   when /^T/
  #     TextFrame
  #   when /^(COM|COMM)$/
  #     CommentsFrame
  #   when /^(ULT|USLT)$/
  #     UnsychronizedTranscriptionFrame
  #   when /^UFID$/
  #     UniqueFileIdFrame
  #   when /^(IPL|IPLS)$/
  #     InvolvedPeopleListFrame
  #   when /^(PIC|APIC)$/
  #     PictureFrame
  #   when /^PRIV$/
  #     PrivateFrame
  #   else
  #     BasicFrame
  #   end
  # end
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
        @by_id[{{id}}]?.try(&.content)
      end
    {% end %}
  end
end
