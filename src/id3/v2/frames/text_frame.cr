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

    def_equals_and_hash id, raw_flags, raw_content, encoding, content

    def initialize(@id, @raw_flags, @encoding, @content)
      io = IO::Memory.new

      io.write_byte(encoding.value)

      # content.join(io, '\0') do |str, io|
      #   io.write(str.to_slice)
      # end

      io.write(content.to_slice)

      @raw_content = io.to_slice
    end

    def initialize(@id, @raw_content, @raw_flags, version : Header::Version)
      @encoding = Encoding.from_value(@raw_content[0])

      string = String.new(@raw_content[1..-1], @encoding.to_s)

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
      io << raw_flags
      io << ", "
      io << encoding
      io << ", "
      io << @raw_content
      io << ", "
      io << content
      io << ")"
    end
  end
end
