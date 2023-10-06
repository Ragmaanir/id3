module Id3::V2
  class ExtendedHeader
    @[Flags]
    enum Flags
      CRC = 0b1000_0000
    end

    def self.read(r : Reader, v : Version)
      size = r.read_int32

      size = if v.major == 3
               # ext. header size for 2.3.0 does not include size bytes.
               # There are only 2 possible sizes - 6 or 10 bytes,
               # which means extended header can take 10 or 14 bytes.
               size + 4
             else
               SynchsafeInt.decode(size)
             end

      flags_value = r.read(2)
    end

    def self.read_extended_header_size(r : Reader, header : Header)
      if header.flags.extended_header?
        size = r.read_int32

        if header.version.major == 3
          # ext. header size for 2.3.0 does not include size bytes.
          # There are only 2 possible sizes - 6 or 10 bytes, which means extended header can take 10 or 14 bytes.
          size + 4
        else
          SynchsafeInt.decode(size)
        end
      else
        0
      end
    end
  end
end
