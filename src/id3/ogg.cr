module Mp3
  class Ogg
    OGG_SYNC_CODE = "OggS"

    def self.is_ogg?(r : Reader)
      id = r.peek_string(4)

      id == OGG_SYNC_CODE
    end
  end
end
