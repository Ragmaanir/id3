class Id3::SynchsafeInt
  def self.decode(s : Int32)
    res = 0

    res |= (s & 0x7F_00_00_00) >> 3
    res |= (s & 0x7F_00_00) >> 2
    res |= (s & 0x7F_00) >> 1
    res |= (s & 0x7F)

    res
  end
end
