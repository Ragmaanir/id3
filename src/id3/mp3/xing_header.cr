class Mp3::XingHeader
  @[Flags]
  enum Fields
    FRAMES  = 1
    SIZE    = 2
    TOC     = 4
    QUALITY = 8
  end

  enum Bitrate
    CBR
    VBR

    def constant?
      self == CBR
    end
  end

  def self.try_read(r : Reader) : XingHeader?
    header = r.peek_string(4)

    if header.in?("Xing", "Info")
      at = r.pos.to_i64
      r.move(4)

      flags = Fields.from_value(r.read_int32)

      frame_count = flags.frames? ? r.read_int32 : 0
      size = flags.size? ? r.read_int32 : 0
      r.move(100) if flags.toc?
      quality = r.read_int32 if flags.quality?

      new(at, header, flags, frame_count, size, quality)
    end
  end

  getter at : Int64
  getter header : String
  getter bitrate : Bitrate
  getter fields : Fields
  getter frame_count : Int32
  getter size : Int32
  getter quality : Int32?

  def initialize(@at, @header, @fields, @frame_count, @size, @quality)
    @bitrate = case header
               when "Info" then Bitrate::CBR
               when "Xing" then Bitrate::VBR
               else             Id3.bug!
               end
  end

  def to_s(io)
    io.puts "Xing Header"
    {
      at:          at,
      header:      header,
      fields:      fields,
      frame_count: frame_count,
      size:        size,
      quality:     quality,
    }.each { |k, v|
      io.print("%-12s" % k)
      io.print ": "
      io.puts v
    }
  end
end
