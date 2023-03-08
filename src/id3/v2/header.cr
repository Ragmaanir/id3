module Id3::V2
  class Header
    SIZE = 10

    def self.read(r : Reader)
      bytes = Bytes.new(SIZE)
      r.read(bytes)
      parse(bytes)
    end

    def self.parse(header : Bytes)
      major = header[3]
      minor = header[4]
      version = Version.new(major, minor)
      flags = header[5]
      tag_size = SynchsafeInt.decode(IO::ByteFormat::BigEndian.decode(Int32, header[6..9]))

      new(version, Flags.from_value(flags.to_i), tag_size)
    end

    @[Flags]
    enum Flags
      Unsynchronization = 0b1000_0000
      ExtendedHeader    = 0b0100_0000
      Experimental      = 0b0010_0000
      Footer            = 0b0001_0000
    end

    getter version : Version
    getter flags : Flags
    getter tag_size : Int32

    def_equals_and_hash version, flags, tag_size

    def initialize(@version, @flags, @tag_size)
    end

    # def to_s(io)
    #   io << version
    #   io << " "
    #   flags.inspect(io)
    #   io << " "
    #   io << tag_size
    # end
  end
end
