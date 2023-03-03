class Id3::V2
  class TextFrame < Frame
    ENCODING_MAP = {
      0b00 => "ISO8859-1",
      0b01 => "UTF-16",
      0b10 => "UTF-16BE",
      0b11 => "UTF-8",
    }

    getter encoding : String
    getter content : String

    def initialize(@id, @raw_content, @raw_flags, @version)
      @encoding = ENCODING_MAP[@raw_content[0]]

      string = String.new(@raw_content[1..-1], @encoding)

      @content = if @version.major >= 4
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
      io << content
      io << ")"
    end
  end
end
