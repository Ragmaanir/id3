class Id3::V2
  class Frame
    @[Flags]
    enum StatusFlags
      DiscardOnTagAlt  = 0b0100_0000
      DiscardOnFileAlt = 0b0010_0000
      Readonly         = 0b0001_0000
    end

    @[Flags]
    enum FormatFlags
      Group               = 0b0100_0000
      Compressed          = 0b0000_1000
      Encrypted           = 0b0000_0100
      Unsynchronised      = 0b0000_0010
      DataLengthIndicator = 0b0000_0001
    end

    getter id : String
    getter raw_flags : Bytes?
    getter raw_content : Bytes
    getter version : Header::Version

    def initialize(@id, @raw_content, @raw_flags, @version)
      # @flags = FrameFlags.new(@flags, @major)
      # @raw_content_io = StringIO.new(@raw_content)
    end

    def content
      # raw_content_io.seek(flags.additional_info_byte_count)
      # if flags.unsynchronised?
      #   StringUtil.undo_unsynchronization(raw_content_io.read)
      # else
      #   raw_content_io.read
      # end
      ""
    end

    def group_id
      if flags.grouped?
        read_additional_info_byte(*flags.position_and_count_of_group_id_bytes)
      end
    end

    def encryption_id
      if flags.encrypted?
        read_additional_info_byte(*flags.position_and_count_of_encryption_id_bytes)
      end
    end

    def read_additional_info_byte(position, byte_count)
      if position && byte_count
        raw_content_io.seek(position)
        raw_content_io.read(byte_count).unpack("C").first
      end
    end

    # def final_size
    #   pos, count = flags.position_and_count_of_data_length_bytes
    #   if (flags.compressed? || flags.data_length_indicator?) && pos && count
    #     raw_content_io.seek(pos)
    #     SynchsafeInt.decode(NumberUtil.convert_string_to_32bit_integer(raw_content_io.read(count)))
    #   else
    #     raw_content_io.size
    #   end
    # end

    def inspect(io)
      io << "Frame("
      io << id
      io << ", "
      io << raw_flags
      io << ", "
      io << content
      io << ")"
    end
  end
end
