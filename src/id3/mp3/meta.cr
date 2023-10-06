module Mp3
  # Responsible for reading meta information about mpeg-frames and
  # the length of an mp3.
  #
  # Resources used:
  #
  # http://www.multiweb.cz/twoinches/mp3inside.htm
  # http://gabriel.mp3-tech.org/mp3infotag.html
  # https://github.com/spreaker/node-mp3-header
  #
  class Meta
    # Reads meta-information of an mp3.
    #
    # *max_scan* is used to specify how many byes into the file to scan for
    # the first frame.
    #
    # Calculating the exact duration of the mp3 can be slow because
    # the whole file has to be read. So the default is to not calculate
    # the exact duration (*fast* = true).
    #
    # TODO: move max_scan default to global config
    def self.read(r : Reader, fast : Bool = true, max_scan : BinarySize = 400.kb)
      f = Id3::TaggedFile.read(r)

      v2 = f.v2

      r.seek(v2.end_pos) if v2

      # If the id3 tag is followed by a Ogg marker, this is an ogg file
      raise "Is an Ogg file, not an mp3" if Ogg.is_ogg?(r)

      first_frame = Frame.find_first_frame(r, max_scan)

      xing = first_frame.xing_frame?(r)

      dur = nil
      frame_count = nil

      if !fast
        dur = 0.seconds
        frame_count = 0

        Frame.each(r, r.size.bytes) do |f|
          frame_count += 1
          dur += f.duration
        end
      end

      Meta.new(r.size, f, first_frame, xing, dur, frame_count)
    end

    getter size : Int64
    getter tags : Id3::TaggedFile
    getter xing_header : XingHeader?
    getter first_frame : Frame
    getter approximate_frame_count : Int32
    getter approximate_duration : Time::Span
    getter duration : Time::Span? = nil
    getter frame_count : Int32? = nil

    def initialize(@size, @tags, @first_frame, @xing_header, @duration, @frame_count)
      @approximate_frame_count = if x = xing_header
                                   x.frame_count
                                 else
                                   # assume CBR and use file size to calculate frame count
                                   ignored = @tags.v2.try(&.size) || 0
                                   ((@size - ignored) / first_frame.size.as_bytes).to_i
                                 end

      # then approximate duration
      @approximate_duration = first_frame.duration * approximate_frame_count
    end

    def to_s(io)
      io.puts "Meta"
      {
        size:             size,
        v2_size:          tags.v2.try(&.size),
        xing_header:      !!xing_header,
        approx_duration:  approximate_duration,
        duration:         duration,
        first_frame:      first_frame.at,
        first_frame_size: first_frame.size,
        frame_duration:   first_frame.duration,
        approx_frames:    @approximate_frame_count,
        frame_count:      frame_count,
      }.each { |k, v|
        io.print("%-12s" % k)
        io.print ": "
        io.puts v
      }
    end
  end
end
