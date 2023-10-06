module Mp3
  class Frame
    SYNC_BYTE = 0xFF

    def self.find_first_frame(r : Reader, max_scan : BinarySize) : Frame?
      find_first_frame?(r, max_scan) || raise "No frame found"
    end

    # def self.find_frame(r : Reader, max_scan : BinarySize) : Frame?
    #   end_pos = [r.size - 1, r.pos + max_scan.as_bytes].min

    #   while (b = r.read_byte) && r.pos < end_pos
    #     if b == SYNC_BYTE
    #       r.move(-1) # move back one byte so we can just read int32
    #       at = r.pos
    #       raw_header = r.read_uint32

    #       header = Header.new(raw_header)

    #       if header.valid?
    #         return Frame.new(at.to_i64, header)
    #       else
    #         r.move(-3)
    #       end
    #     else
    #       # skip
    #     end
    #   end
    # end

    def self.find_first_frame?(r : Reader, max_scan : BinarySize) : Frame?
      each(r, max_scan) do |f|
        return f
      end
    end

    # Scan for the first frame and from there on iterate over each mp3 frame
    def self.each(r : Reader, max_scan : BinarySize, &block : Frame -> _)
      end_pos = [r.size - 1, r.pos + max_scan.as_bytes].min

      while (b = r.read_byte) && r.pos < end_pos
        if b == SYNC_BYTE
          r.move(-1) # move back one byte so we can just read int32
          at = r.pos
          raw_header = r.read_uint32

          header = Header.new(raw_header)

          if header.valid?
            f = Frame.new(at.to_i64, header)
            yield(f)
            r.move(f.size.as_bytes - 4)
          else
            r.move(-3)
          end
        else
          # skip
        end
      end
    end

    getter header : Header
    getter at : Int64

    def initialize(@at, @header)
    end

    def size
      header.frame_size
    end

    def duration
      header.frame_duration
    end

    def xing_frame?(r : Reader)
      r.seek(at + header.xing_header_offset.as_bytes)

      XingHeader.try_read(r)
    end
  end
end
