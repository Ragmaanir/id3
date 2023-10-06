module Id3::V2
  # SPEC(2.3, 2.4):
  #
  # This frame is intended for one-string text information concerning the
  #  audio file in a similar way to the other "T"-frames. The frame body
  #  consists of a description of the string, represented as a terminated
  #  string, followed by the actual string. There may be more than one
  #  "TXXX" frame in each tag, but only one with the same description.
  #
  #    <Header for 'User defined text information frame', ID: "TXXX">
  #    Text encoding     $xx
  #    Description       <text string according to encoding> $00 (00)
  #    Value             <text string according to encoding>
  #
  class UserDefinedTextFrame < Frame
    getter encoding : Encoding
    getter description : String
    getter value : String

    def_equals_and_hash id, size, flags, body, encoding, description, value

    def self.create(id, version, size, flags, encoding : Encoding, content)
      io = IO::Memory.new

      io.write_byte(encoding.value)

      io.write(content.to_slice)

      new(id, version, size, flags, io.to_slice)
    end

    def initialize(id, version, size, flags, raw_body)
      super(id, version, size, flags, raw_body)

      @encoding = Encoding.from_value(@body[0])

      rest = @body[1..-1]

      # NOTE: this only takes the first two values and ignores the rest
      @description, @value = encoding.read_multiple_strings(rest)
    end

    private def extra_attributes
      [
        encoding.to_s,
        description.inspect.colorize(:yellow),
        value.inspect.colorize(:yellow),
      ]
    end
  end
end
