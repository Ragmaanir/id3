class Id3::Reader
  getter io : IO
  getter size : Int64

  def initialize(@io, @size)
  end

  def initialize(path : Path)
    initialize(File.new(path))
  end

  def initialize(io : File)
    initialize(io, io.size)
  end

  def initialize(bytes : Bytes)
    initialize(IO::Memory.new(bytes, false), bytes.size)
  end

  delegate read_fully, read_byte, read_bytes, read_string, seek, pos, to: @io

  def read(n : Int32)
    s = Bytes.new(n)
    # NOTE: IO.read(Bytes) only reads up to 32758, IO.read_fully(Bytes) reads all
    @io.read_fully(s)
    s
  end

  def read_int32
    read_bytes(Int32, IO::ByteFormat::BigEndian)
  end

  def read_uint32
    read_bytes(UInt32, IO::ByteFormat::BigEndian)
  end

  def peek_byte : UInt8?
    b = io.read_byte
    move(-1) if b
    b
  end

  def peek(n : Int32) : Bytes
    bytes = read(n)
    move(-n)
    bytes
  end

  def peek_string(n : Int32) : String
    str = read_string(n)
    move(-n)
    str
  end

  def move(n : Int32 | Int64)
    seek(n, IO::Seek::Current)
  end

  def remaining_size
    size - pos
  end
end
