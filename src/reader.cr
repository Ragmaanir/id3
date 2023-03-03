class Id3::Reader < IO
  @io : IO
  getter size : Int64

  def initialize(@io, @size)
  end

  def initialize(io : File)
    initialize(io, io.size)
  end

  def initialize(bytes : Bytes)
    initialize(IO::Memory.new(bytes, false), bytes.size)
  end

  # def read(slice : Bytes)
  # end

  delegate read, seek, peek, to: @io

  def write(slice : Bytes) : Nil
    raise "readonly"
  end

  def read(n : Int32)
    s = Bytes.new(n)
    @io.read(s) == n || raise("Unexpected EOF")
    s
  end

  def read_int32
    read_bytes(Int32, IO::ByteFormat::BigEndian)
  end

  def peek_byte : UInt8?
    case bytes = peek
    when nil     then raise("IO does not support peek")
    when .empty? then nil # eof
    else
      bytes[0]
    end
  end
end
