require "./text_frame"

module Id3::V2
  # SPEC(2.3, 2.4):
  #
  # This frame is intended for any kind of full text information that
  #  does not fit in any other frame. It consists of a frame header
  #  followed by encoding, language and content descriptors and is ended
  #  with the actual comment as a text string. Newline characters are
  #  allowed in the comment text string. There may be more than one
  #  comment frame in each tag, but only one with the same language and
  #  content descriptor.
  #
  #    <Header for 'Comment', ID: "COMM">
  #    Text encoding          $xx
  #    Language               $xx xx xx
  #    Short content descrip. <text string according to encoding> $00 (00)
  #    The actual text        <full text string according to encoding>
  #
  class CommentFrame < Frame
    include FrameWithContent

    getter encoding : Encoding
    getter language : String
    getter description : String
    getter content : String

    def_equals_and_hash id, size, flags, body, encoding, language, description, content

    def self.create(id, version, size, flags, encoding : Encoding, language, description, content)
      io = IO::Memory.new

      io.write_byte(encoding.value)

      # TODO: use enum
      io.write(language.to_slice)
      io.write(description.to_slice)
      io.write("\0".to_slice)
      io.write(content.to_slice)

      new(id, version, size, flags, io.to_slice)
    end

    def initialize(id, version, size, flags, raw_body)
      super(id, version, size, flags, raw_body)

      @encoding = Encoding.from_value(@body[0])

      @language = String.new(@body[1..3]) # TODO: use enum
      rest = @body[4..-1]

      @description, @content = encoding.read_multiple_strings(rest)
    end

    private def extra_attributes
      [
        encoding.to_s,
        language.inspect,
        description.inspect,
        content.inspect.colorize(:yellow),
      ]
    end
  end
end
