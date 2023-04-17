module Id3::V2
  class Frame
    Log = ::Log.for(self)

    def self.valid_id?(id : String)
      /\A[A-Z0-9]{3,4}\z/ === id
    end

    def self.from_id(id : String)
      case id
      when /\AT/
        TextFrame
      else
        Frame
      end
    end

    def self.read_all(r : Reader, header : Header)
      Log.trace { "read_all" }

      frames = [] of Frame

      loop do
        frames << Frame.read(r, header.version)

        b = r.peek_byte
        break if b == nil || b == 0 # eof or padding
      end

      Log.trace { "read_all completed (#{frames.size} Frames)" }

      frames
    end

    # def self.read_all(r : Reader, frames_end_pos : Int64, header : Header)
    #   Log.trace { "read_all" }

    #   frames = [] of Frame

    #   loop do
    #     frames << Frame.read(r, header.version)

    #     break if r.pos >= frames_end_pos
    #     break if r.peek_byte == 0 # padding
    #   end

    #   Log.trace { "read_all completed (#{frames.size} Frames)" }

    #   frames
    # end

    def self.read(r : Reader, version : Version)
      Log.trace &.emit("read", at: r.pos)

      major = version.major

      frame_id_length = major <= 2 ? 3 : 4

      id = r.read_string(frame_id_length)

      Log.trace &.emit("id", id: id)

      if !valid_id?(id)
        raise ValidationException.new("Frame id is invalid: #{id}")
      end

      size = case major
             when 4
               SynchsafeInt.decode(r.read_int32)
             when 3
               r.read_int32
             when 2
               bytes = Bytes[0x0, 0x0, 0x0, 0x0]
               r.read_fully(bytes[1, 3]) == 3 || raise("Unexpected EOF")
               IO::ByteFormat::BigEndian.decode(Int32, bytes)
             else Id3.bug!("An invalid major version number should not be detected here: #{major}")
             end

      # FIXME: validate size

      Log.trace &.emit("size", size: size)

      flags = nil

      if major > 2 # has flags
        flag_bytes = r.read(2)

        e = major == 2 ? OldFlags : NewFlags

        Log.trace &.emit("flag bytes", kind: e.name.split("::").last, status: flag_bytes[0].to_i, format: flag_bytes[1].to_i)

        flags = e.new(flag_bytes[0], flag_bytes[1])
      end

      body = r.read(size)

      Log.trace &.emit("read completed")

      Frame.from_id(id).new(id, version, size, flags, body)
    end

    record(NewFlags, status : StatusFlags, format : FormatFlags) do
      def initialize(s : UInt8, f : UInt8)
        @status = StatusFlags.from_value(s)
        @format = FormatFlags.from_value(f)
      end

      def inspect(io)
        io << "NewFlags("
        status.to_s(io)
        io << ", "
        format.to_s(io)
        io << ")"
      end
    end

    record(OldFlags, status : OldStatusFlags, format : OldFormatFlags) do
      def initialize(s : UInt8, f : UInt8)
        @status = OldStatusFlags.from_value(s)
        @format = OldFormatFlags.from_value(f)
      end

      def inspect(io)
        io << "NewFlags("
        status.to_s(io)
        io << ", "
        format.to_s(io)
        io << ")"
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
    getter size : Int32
    getter flags : NewFlags | OldFlags | Nil
    getter extra_flag_bytes : Int32
    getter body : Bytes

    getter encryption : UInt8?
    getter group : UInt8?
    getter compression_size : Int32?

    def_equals_and_hash id, size, flags, body

    def initialize(@id, version : Version, @size, @flags, raw_body)
      @extra_flag_bytes = 0

      final_body = raw_body

      if f = @flags
        efb = 0

        if f.format.grouped?
          @encryption = raw_body[efb]
          efb += 1
        end

        if f.format.compressed?
          @compression_size = IO::ByteFormat::BigEndian.decode(Int32, raw_body[efb..efb + 4])
          efb += 4
        end

        if f.format.encrypted?
          @encryption = raw_body[efb]
          efb += 1
        end

        if f.format.data_length_indicator?
          efb += 4
        end

        @extra_flag_bytes = efb

        if f.format.unsynchronized?
          final_body = UnsynchronizationScheme.unapply(raw_body[@extra_flag_bytes..-1])
        end
      end

      @body = final_body

      # TODO: decompression/decryption
      # TODO: lazy decompression etc?
    end

    def inspect(io)
      io << "Frame("
      io << id
      io << ", "
      io << size
      io << ", "
      flags.inspect(io)
      # io << ", "
      # io << body
      io << ")"
    end
  end
end
