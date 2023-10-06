require "./encoding"
require "./flags"

module Id3::V2
  module FrameWithContent
    abstract def content : String
  end

  class Frame
    Log = ::Log.for(self)

    def self.valid_id?(id : String)
      /\A[A-Z0-9]{3,4}\z/ === id
    end

    def self.from_id(id : String)
      case id
      when /\ATXXX/
        UserDefinedTextFrame
      when /\AT/
        TextFrame
      when /\ACOMM/
        CommentFrame
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
    end

    private def class_name
      self.class.name.split("::").last
    end

    def pretty_print(pp : PrettyPrint)
      pp.text class_name.colorize(:cyan)

      pp.text "("
      pp.text id.colorize(:green)
      pp.text ", "
      pp.text size
      pp.text ", "
      flags.pretty_print(pp)

      extra_attributes.each do |att|
        pp.text ", "
        pp.text att
      end
      pp.text ")"
    end

    private def extra_attributes
      [] of String
    end
  end
end
