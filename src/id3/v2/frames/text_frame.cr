module Id3::V2
  class TextFrame < Frame
    enum Encoding : UInt8
      ISO8859_1 = 0b00
      UTF_16    = 0b01
      UTF_16BE  = 0b10
      UTF_8     = 0b11

      def to_s
        super.sub("_", "-")
      end
    end

    getter encoding : Encoding
    getter content : String

    def_equals_and_hash id, status_flags, format_flags, body, encoding, content

    def initialize(id, version, status_flags, format_flags, @encoding, @content)
      io = IO::Memory.new

      io.write_byte(encoding.value)

      io.write(content.to_slice)

      super(id, version, status_flags, format_flags, io.to_slice)
    end

    def initialize(id, version, status_flags, format_flags, body)
      @encoding = Encoding.from_value(body[0])

      string = String.new(body[1..-1], @encoding.to_s)

      @content = if version.major >= 4
                   string.chomp('\0')
                 else
                   string.split('\0', 2).first
                 end

      super(id, version, status_flags, format_flags, body)
    end

    # def inspect(io)
    #   io << "TextFrame("
    #   io << id
    #   io << ", "
    #   io << raw_flags
    #   io << ", "
    #   io << encoding
    #   io << ", "
    #   io << @raw_content
    #   io << ", "
    #   io << content
    #   io << ")"
    # end
  end
end
