class Id3::V2::Frame
  @[Flags]
  enum StatusFlags : UInt8
    DiscardOnTagAlt  = 0b0100_0000
    DiscardOnFileAlt = 0b0010_0000
    Readonly         = 0b0001_0000
  end

  @[Flags]
  enum FormatFlags : UInt8
    Grouped             = 0b0100_0000
    Compressed          = 0b0000_1000
    Encrypted           = 0b0000_0100
    Unsynchronized      = 0b0000_0010
    DataLengthIndicator = 0b0000_0001
  end

  @[Flags]
  enum OldStatusFlags : UInt8
    DiscardOnTagAlt  = 0b0100_0000
    DiscardOnFileAlt = 0b0010_0000
    Readonly         = 0b0001_0000
  end

  @[Flags]
  enum OldFormatFlags : UInt8
    Grouped             = 0b0100_0000
    Compressed          = 0b0000_1000
    Encrypted           = 0b0000_0100
    Unsynchronized      = 0b0000_0010
    DataLengthIndicator = 0b0000_0001
  end

  record(NewFlags, status : StatusFlags, format : FormatFlags) do
    def initialize(s : UInt8, f : UInt8)
      @status = StatusFlags.from_value(s)
      @format = FormatFlags.from_value(f)
    end

    def pretty_print(pp : PrettyPrint)
      pp.text "NewFlags".colorize(:cyan)

      pp.text "("
      pp.text status.to_s
      pp.text ", "
      pp.text format.to_s
      pp.text ")"
    end
  end

  record(OldFlags, status : OldStatusFlags, format : OldFormatFlags) do
    def initialize(s : UInt8, f : UInt8)
      @status = OldStatusFlags.from_value(s)
      @format = OldFormatFlags.from_value(f)
    end

    def pretty_print(pp : PrettyPrint)
      pp.text "OldFlags".colorize(:cyan)

      pp.text "("
      pp.text status.to_s
      pp.text ", "
      pp.text format.to_s
      pp.text ")"
    end
  end
end
