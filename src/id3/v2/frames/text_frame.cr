module Id3::V2
  class TextFrame < Frame
    # ENCODING_MAP = {
    #   0b00 => "ISO8859-1",
    #   0b01 => "UTF-16",
    #   0b10 => "UTF-16BE",
    #   0b11 => "UTF-8",
    # }

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
    getter content : Array(String)

    def_equals_and_hash id, raw_flags, raw_content, encoding, content

    def initialize(@id, @raw_flags, @encoding, @content)
      io = IO::Memory.new

      io.write_byte(encoding.value)

      content.join(io, '\u0000') do |str, io|
        io.write(str.to_slice)
      end

      @raw_content = io.to_slice

      # byte_size = 1 + @content.map(&.bytesize).sum + @content.size
      # @raw_content = Bytes.new(byte_size)
      # @raw_content[0] = encoding.value

      # @raw_content = (encoding.value + content.map { |s| s + '\u0000' }.join).to_slice

      # XXX
      # byte_size = 1 + @content.map(&.bytesize).sum + (@content.size - 1)
      # bytes = Bytes.new(byte_size)

      # bytes[0] = encoding.value

      # idx = 1
      # content.each do |str|
      #   str.each_byte { |b|
      #     bytes[idx] = b
      #     idx += 1
      #   }
      #   if idx < byte_size
      #     bytes[idx] = 0
      #     idx += 1
      #   end
      # end
      # @raw_content = bytes
      # XXX

      # bytes = [] of UInt8
      # bytes << encoding.value
      # content.each do |str|
      #   str.each_byte { |b| bytes << b }
      #   bytes << 0
      # end
      # @raw_content = Bytes.new(bytes)
    end

    def initialize(@id, @raw_content, @raw_flags, version : Header::Version)
      # @encoding = ENCODING_MAP[@raw_content[0]]
      @encoding = Encoding.from_value(@raw_content[0])

      string = String.new(@raw_content[1..-1], @encoding.to_s)

      @content = if version.major >= 4
                   [string.chomp('\0')]
                 else
                   string.split('\0')
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
