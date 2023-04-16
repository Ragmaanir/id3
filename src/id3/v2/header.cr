module Id3::V2
  class Header
    Log = ::Log.for(self)

    SIZE = 10

    def self.read(r : Reader)
      header_bytes = r.read(SIZE)
      read(header_bytes)
    end

    def self.read(header : Bytes)
      Log.trace &.emit("read")

      major = header[3]
      minor = header[4]
      version = Version.new(major, minor)

      Log.trace &.emit("version", major: major.to_i, minor: minor.to_i)

      raw_flags = header[5]
      flags = Flags.from_value(raw_flags.to_i)

      Log.trace &.emit("flags", flags: flags.to_s)

      tag_size = SynchsafeInt.decode(IO::ByteFormat::BigEndian.decode(Int32, header[6..9]))

      Log.trace &.emit("read completed", major: major.to_i, minor: minor.to_i, size: tag_size)

      new(version, flags, tag_size)
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

    def inspect(io)
      io << "Header("
      io << version
      io << ","
      flags.to_s(io)
      io << ","
      io << tag_size
      io << ")"
    end
  end
end
