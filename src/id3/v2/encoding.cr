class Id3::V2::Frame
  enum Encoding : UInt8
    ISO8859_1 = 0b00
    UTF_16    = 0b01
    UTF_16BE  = 0b10
    UTF_8     = 0b11

    def to_s
      super.sub("_", "-")
    end

    private def terminator
      case step
      when 2 then Bytes[0, 0]
      else        Bytes[0]
      end
    end

    private def step
      case self
      when UTF_16, UTF_16BE then 2
      else                       1
      end
    end

    def read_multiple_strings(slice : Bytes) : Array(String)
      split_by_terminator(slice).map { |s| String.new(s, to_s) }
    end

    # Split the slice by null-terminators (which can be 1 or 2 bytes)
    def split_by_terminator(slice : Bytes) : Array(Bytes)
      res = [] of Bytes

      last_end = 0
      i = 0

      while i < slice.size
        if slice[i, step] == terminator
          res << slice[last_end, i - last_end]
          last_end = i + step # skip terminator
        end

        i += step
      end

      res << slice[last_end..-1]

      res
    end
  end
end
