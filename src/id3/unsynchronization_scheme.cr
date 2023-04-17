# ID3 'unsynchronization scheme'
# Bit sequences like:
#
#   `11111111 111xxxxx`
#
# will be encoded as:
#
#   `11111111 00000000 111xxxxx`
#
# in order to prevent old software/players from interpreting
# the sequence as an incorrect synchronization sequence.
# In addition, now the sequence `FF 00` has to be escaped
# by inserting a null byte: `FF 00 00`.
module Id3::UnsynchronizationScheme
  def self.apply(bytes : Bytes) : Bytes
    io = IO::Memory.new(bytes.size)

    bytes.each_with_index do |cur, i|
      n = bytes[i + 1]?

      io.write_byte(cur)

      if cur == 0xFF
        if n && n >= 0b11100000
          io.write_byte(NULL_BYTE)
        elsif n == 0x00
          io.write_byte(NULL_BYTE)
        end
      end
    end

    io.to_slice
  end

  def self.unapply(bytes : Bytes) : Bytes
    # FIXME: use capacity?
    io = IO::Memory.new

    prev = nil

    bytes.each_with_index do |cur, i|
      if prev != 0xFF
        # first byte or not a possible escape sequence
        io.write_byte(cur)
      else
        # possible escape sequence encountered
        if cur == NULL_BYTE && (n = bytes[i + 1]?)
          if n == NULL_BYTE || n >= 0b11100000
            # escaped NULL_BYTE or SYNC byte encountered, so we skip it
          else
            io.write_byte(cur)
          end
        else
          io.write_byte(cur)
        end
      end

      prev = cur
    end

    io.to_slice
  end
end
