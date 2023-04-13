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

    def_equals_and_hash id, flags, body, encoding, content

    def initialize(id, version, flags, @encoding, @content)
      io = IO::Memory.new

      io.write_byte(encoding.value)

      io.write(content.to_slice)

      super(id, version, flags, io.to_slice)
    end

    def initialize(id, version, flags, raw_body)
      super(id, version, flags, raw_body)

      @encoding = Encoding.from_value(@body[0])

      string = String.new(@body[1..-1], @encoding.to_s)

      @content = if version.major >= 4
                   string.chomp('\0')
                 else
                   string.split('\0', 2).first
                 end
    end

    def inspect(io)
      io << "TextFrame("
      io << id
      io << ", "
      flags.inspect(io)
      io << ", "
      encoding.inspect(io)
      io << ", "
      content.inspect(io)
      io << ")"
    end
  end
end
