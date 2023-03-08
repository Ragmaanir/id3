module Id3::V2
  class Frame
    def self.from_id(id : String)
      case id
      when /^T/
        TextFrame
      else
        Frame
      end
    end

    def self.read_all(r : Reader, version : Version)
      frames = [] of Frame

      loop do
        frames << Frame.read(r, version)

        b = r.peek_byte
        break if b == nil || b == 0 # eof or padding
      end

      frames
    end

    def self.read(r : IO, version : Version)
      major = version.major

      frame_id_length = major <= 2 ? 3 : 4

      id = r.read_string(frame_id_length)

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

      Frame.from_id(id).new(
        id,
        version,
        flags,
        content
      )
    end

    @[Flags]
    enum StatusFlags
      DiscardOnTagAlt  = 0b0100_0000
      DiscardOnFileAlt = 0b0010_0000
      Readonly         = 0b0001_0000
    end

    @[Flags]
    enum FormatFlags
      Group               = 0b0100_0000
      Compressed          = 0b0000_1000
      Encrypted           = 0b0000_0100
      Unsynchronised      = 0b0000_0010
      DataLengthIndicator = 0b0000_0001
    end

    @[Flags]
    enum OldStatusFlags
      DiscardOnTagAlt  = 0b0100_0000
      DiscardOnFileAlt = 0b0010_0000
      Readonly         = 0b0001_0000
    end

    @[Flags]
    enum OldFormatFlags
      Group               = 0b0100_0000
      Compressed          = 0b0000_1000
      Encrypted           = 0b0000_0100
      Unsynchronised      = 0b0000_0010
      DataLengthIndicator = 0b0000_0001
    end

    getter id : String
    getter! format_flags : FormatFlags | OldFormatFlags
    getter! status_flags : StatusFlags | OldStatusFlags
    getter raw_flags : Bytes?
    getter raw_content : Bytes

    def_equals_and_hash id, raw_flags, raw_content

    def initialize(@id, version : Version, @raw_flags, @raw_content)
      if rf = @raw_flags
        if version.major == 2
          @format_flags = OldFormatFlags.from_value(rf[0].to_i)
          @status_flags = OldStatusFlags.from_value(rf[1].to_i)
        else
          @format_flags = FormatFlags.from_value(rf[0].to_i)
          @status_flags = StatusFlags.from_value(rf[1].to_i)
        end
      end
      # @raw_content_io = StringIO.new(@raw_content)
    end

    def content
      # raw_content_io.seek(flags.additional_info_byte_count)
      # if flags.unsynchronised?
      #   StringUtil.undo_unsynchronization(raw_content_io.read)
      # else
      #   raw_content_io.read
      # end
      ""
    end

    def group_id
      if flags.grouped?
        read_additional_info_byte(*flags.position_and_count_of_group_id_bytes)
      end
    end

    def encryption_id
      if flags.encrypted?
        read_additional_info_byte(*flags.position_and_count_of_encryption_id_bytes)
      end
    end

    def read_additional_info_byte(position, byte_count)
      if position && byte_count
        raw_content_io.seek(position)
        raw_content_io.read(byte_count).unpack("C").first
      end
    end

    # def final_size
    #   pos, count = flags.position_and_count_of_data_length_bytes
    #   if (flags.compressed? || flags.data_length_indicator?) && pos && count
    #     raw_content_io.seek(pos)
    #     SynchsafeInt.decode(NumberUtil.convert_string_to_32bit_integer(raw_content_io.read(count)))
    #   else
    #     raw_content_io.size
    #   end
    # end

    # def inspect(io)
    #   io << "Frame("
    #   io << id
    #   io << ", "
    #   io << raw_flags
    #   io << ", "
    #   io << raw_content
    #   # io << content
    #   io << ")"
    # end
  end
end
