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

      flags = nil

      if major > 2 # has flags
        flag_bytes = r.read(2)

        e = major == 2 ? OldFlags : NewFlags

        flags = e.new(flag_bytes[0], flag_bytes[1])
      end

      body = r.read(size)

      Frame.from_id(id).new(id, version, flags, body)
    end

    record(NewFlags, status : StatusFlags, format : FormatFlags) do
      def initialize(s : UInt8, f : UInt8)
        @status = StatusFlags.from_value(s)
        @format = FormatFlags.from_value(f)
      end
    end

    record(OldFlags, status : OldStatusFlags, format : OldFormatFlags) do
      def initialize(s : UInt8, f : UInt8)
        @status = OldStatusFlags.from_value(s)
        @format = OldFormatFlags.from_value(f)
      end
    end

    @[Flags]
    enum StatusFlags : UInt8
      DiscardOnTagAlt  = 0b0100_0000
      DiscardOnFileAlt = 0b0010_0000
      Readonly         = 0b0001_0000
    end

    @[Flags]
    enum FormatFlags : UInt8
      Grouped             = 0b0100_0000
      Compressed          = 0b0000_1000
      Encrypted           = 0b0000_0100
      Unsynchronized      = 0b0000_0010
      DataLengthIndicator = 0b0000_0001
    end

    @[Flags]
    enum OldStatusFlags : UInt8
      DiscardOnTagAlt  = 0b0100_0000
      DiscardOnFileAlt = 0b0010_0000
      Readonly         = 0b0001_0000
    end

    @[Flags]
    enum OldFormatFlags : UInt8
      Grouped             = 0b0100_0000
      Compressed          = 0b0000_1000
      Encrypted           = 0b0000_0100
      Unsynchronized      = 0b0000_0010
      DataLengthIndicator = 0b0000_0001
    end

    getter id : String
    getter flags : NewFlags | OldFlags | Nil
    getter extra_flag_bytes : Int32
    getter body : Bytes

    getter encryption : UInt8?
    getter group : UInt8?
    getter compression_size : Int32?

    def_equals_and_hash id, flags, body

    def initialize(@id, version : Version, @flags, @body)
      @extra_flag_bytes = 0

      if f = @flags
        efb = 0

        if f.format.grouped?
          @encryption = @body[efb]
          efb += 1
        end

        if f.format.compressed?
          @compression_size = IO::ByteFormat::BigEndian.decode(Int32, @body[efb..efb + 4])
          efb += 4
        end

        if f.format.encrypted?
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
