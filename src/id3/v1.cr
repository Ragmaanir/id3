require "./v1/genre"

module Id3::V1
  Log = ::Log.for(self)

  IDENTIFIER = "TAG"
  TAG_SIZE   = 128

  def self.present?(r : Reader)
    if r.size >= TAG_SIZE
      r.seek(-TAG_SIZE, IO::Seek::End)
      r.peek_string(3) == IDENTIFIER
    end
  end

  def self.read(r : Reader)
    Log.trace { "Reading" }
    version = 0

    r.seek(-TAG_SIZE + 3, IO::Seek::End)

    title_bytes = r.read(30)
    artist_bytes = r.read(30)
    album_bytes = r.read(30)
    year_bytes = r.read(4)
    comment_bytes = r.read(30)
    track = nil
    genre = Genre.from_value?(r.read(1)[0].to_i)

    t_idx = (title_bytes.index(NULL_BYTE) || 30)
    a_idx = (artist_bytes.index(NULL_BYTE) || 30)
    b_idx = (album_bytes.index(NULL_BYTE) || 30)
    c_idx = (comment_bytes.index(NULL_BYTE) || 30)

    title = String.new(title_bytes[0..t_idx - 1]) unless t_idx == 0
    artist = String.new(artist_bytes[0..a_idx - 1]) unless a_idx == 0
    album = String.new(album_bytes[0..b_idx - 1]) unless b_idx == 0
    comment = String.new(comment_bytes[0..c_idx - 1]) unless c_idx == 0
    year = String.new(year_bytes) unless year_bytes[0] == 0

    if comment_bytes[28] == NULL_BYTE && comment_bytes[29] != NULL_BYTE
      version = 1
      track = comment_bytes[29].to_s
    end

    Log.trace { "Reading completed" }

    Tag.new(version, title, artist, album, year, comment, track, genre)
  end

  class Tag
    getter version : Int32
    getter title : String?
    getter artist : String?
    getter album : String?
    getter year : String?
    getter comment : String?
    getter track : String?
    getter genre : Genre?

    def initialize(@version, @title, @artist, @album, @year, @comment, @track, @genre)
    end
  end
end
