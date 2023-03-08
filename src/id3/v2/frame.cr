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

      # TODO: move to flags-object?
      sf = nil
      ff = nil

      if major > 2 # has flags
        flag_bytes = r.read(2)
        sfv, ffv = flag_bytes[0].to_i, flag_bytes[1].to_i

        if major == 2
          sf = OldStatusFlags.from_value(sfv)
          ff = OldFormatFlags.from_value(ffv)
        else
          sf = StatusFlags.from_value(sfv)
          ff = FormatFlags.from_value(ffv)
        end
      end

      body = r.read(size)

      Frame.from_id(id).new(id, version, sf, ff, body)
    end

    @[Flags]
    enum StatusFlags
      DiscardOnTagAlt  = 0b0100_0000
      DiscardOnFileAlt = 0b0010_0000
      Readonly         = 0b0001_0000
    end

    @[Flags]
    enum FormatFlags
      Grouped             = 0b0100_0000
      Compressed          = 0b0000_1000
      Encrypted           = 0b0000_0100
      Unsynchronized      = 0b0000_0010
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
      Grouped             = 0b0100_0000
      Compressed          = 0b0000_1000
      Encrypted           = 0b0000_0100
      Unsynchronized      = 0b0000_0010
      DataLengthIndicator = 0b0000_0001
    end

    getter id : String
    getter status_flags : StatusFlags | OldStatusFlags | Nil
    getter format_flags : FormatFlags | OldFormatFlags | Nil
    getter extra_flag_bytes : Int32
    getter body : Bytes

    getter encryption : UInt8?
    getter group : UInt8?
    getter compression_size : Int32?

    def_equals_and_hash id, status_flags, format_flags, body

    def initialize(@id, version : Version, @status_flags, @format_flags, @body)
      @extra_flag_bytes = 0

      if ff = @format_flags
        efb = 0

        if ff.grouped?
          @encryption = @body[efb]
          efb += 1
        end

        if ff.compressed?
          @compression_size = IO::ByteFormat::BigEndian.decode(Int32, @body[efb..efb + 4])
          efb += 4
        end

        if ff.encrypted?
          @encryption = @body[efb]
          efb += 1
        end

        @extra_flag_bytes = efb
      end

      # TODO: decompression/decryption
      # TODO: lazy decompression etc?

      # decoded_content = if format_flags.unsynchronized?
      #                     UnsynchronizationScheme.unapply(@body[@extra_flag_bytes..-1])
      #                   else
      #                     body
      #                   end

      # @content = String.new(decoded_content)
    end

    # def content
    #   # raw_content_io.seek(flags.additional_info_byte_count)
    #   # if flags.unsynchronised?
    #   #   StringUtil.undo_unsynchronization(raw_content_io.read)
    #   # else
    #   #   raw_content_io.read
    #   # end
    #   ""
    # end

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
