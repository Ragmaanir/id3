module Id3::V2
  class TextFrame < Frame
    include FrameWithContent

    getter encoding : Encoding
    getter contents : Array(String)

    def_equals_and_hash id, size, flags, body, encoding, contents

    def self.create(id, version, size, flags, encoding : Encoding, content : String)
      create(id, version, size, flags, encoding, [content])
    end

    def self.create(id, version, size, flags, encoding : Encoding, contents : Array(String))
      io = IO::Memory.new

      io.set_encoding(encoding.to_s)
      io.write_byte(encoding.value)

      contents.join(io, "\0") do |c, io|
        io.write(c.to_slice)
      end

      new(id, version, size, flags, io.to_slice)
    end

    def initialize(id, version, size, flags, raw_body)
      super(id, version, size, flags, raw_body)

      @encoding = Encoding.from_value(@body[0])

      # SPEC(v2.3):
      # If the textstring is followed by a termination ($00 (00))
      # all the following information should be ignored and not be displayed.
      #
      # SPEC(v2.4):
      # All text information frames supports multiple strings,
      # stored as a null separated list, where null is reperesented
      # by the termination code for the charater encoding.

      rest = @body[1..-1]

      @contents = encoding.read_multiple_strings(rest)
    end

    def content : String
      contents.first
    end

    private def extra_attributes
      [
        encoding.to_s,
        contents.map(&.colorize(:yellow)),
      ]
    end
  end
end
