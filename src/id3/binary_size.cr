class BinarySize
  include Comparable(BinarySize)

  enum Magnitude
    KILO = 1
    MEGA
    GIGA
    TERA
    PETA

    def decimal_factor
      1000_i64 ** self.value
    end

    def binary_factor
      1024_i64 ** self.value.to_i64
    end

    def abbreviation
      self.to_s[0]
    end
  end

  getter bits : Int64

  def initialize(@bits)
  end

  def <=>(other : BinarySize)
    bits <=> other.bits
  end

  def +(other : BinarySize)
    self.class.new(bits + other.bits)
  end

  # Return true iif size is byte-aligned (e.g. 32 bits, but not 3 bits)
  def byte_based?
    bits.bits(0..2) == 0
  end

  def as_bytes : Int64
    raise "#{bits} is not divisible by 8 and cannot be interpreted as bytes" unless byte_based?
    to_bytes
  end

  def to_bytes : Int64
    (bits / 8).to_i64
  end

  # TODO: to_kb, to_mb, ...

  def to_s(io)
    io << bits
    # if byte_based?
    #   io << as_bytes
    # else
    # end
  end

  def inspect(io)
    io << "BinarySize("
    io << @bits
    io << ")"
  end
end

struct Int
  def bits
    BinarySize.new(self)
  end

  def bytes
    (self * 8).bits
  end

  {% for c in BinarySize::Magnitude.constants %}
    {% abbr = c.stringify.downcase[0..0].id %}
    {% u = "BinarySize::Magnitude::#{c}".id %}

    def {{abbr}}bit
      (self.to_i64 * {{u}}.decimal_factor).bits
    end

    def {{abbr}}ibit
      (self.to_i64 * {{u}}.binary_factor).bits
    end

    def {{abbr}}b
      (self.to_i64 * {{u}}.decimal_factor).bytes
    end

    def {{abbr}}ibyte
      (self.to_i64 * {{u}}.binary_factor).bytes
    end
  {% end %}
end
