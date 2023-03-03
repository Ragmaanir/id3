require "./synchsafe_int"
require "./reader"
require "./id3/v1"
require "./id3/v2"

module Id3
  def self.read(r : Reader)
    if r.size > V2::Header::SIZE
      id = r.read_string(3)

      if id == Id3::V2::IDENTIFIER
        r.seek(0) # FIXME: this is ugly. the id should be peeked instead of read.
        Id3::V2.read(r)
      elsif r.size > Id3::V1::TAG_SIZE
        r.seek(-Id3::V1::TAG_SIZE, IO::Seek::End)
        r.read(3) == Id3::V1::IDENTIFIER # FIXME: raise

        Id3::V1.read(r)
      end
    end
  end
end
