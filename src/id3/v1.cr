require "./v1/genre"

module Id3::V1
  IDENTIFIER = "TAG"
  TAG_SIZE   = 128

  def self.present?(r : Reader)
    if r.size >= TAG_SIZE
      r.seek(-TAG_SIZE, IO::Seek::End)
      r.peek_string(3) == IDENTIFIER
    end
  end

  def self.read(r : Reader)
    version = 0

    r.seek(-TAG_SIZE + 3, IO::Seek::End)

    title_bytes = r.read(30)
    artist_bytes = r.read(30)
    album_bytes = r.read(30)
    year = String.new(r.read(4))
    comment_bytes = r.read(30)
    track = nil
    genre = Genre.from_value(r.read(1)[0].to_i)

    t_idx = (title_bytes.index(NULL_BYTE) || 30) - 1
    a_idx = (artist_bytes.index(NULL_BYTE) || 30) - 1
    b_idx = (album_bytes.index(NULL_BYTE) || 30) - 1
    c_idx = (comment_bytes.index(NULL_BYTE) || 30) - 1

    title = String.new(title_bytes[0..t_idx])
    artist = String.new(artist_bytes[0..a_idx])
    album = String.new(album_bytes[0..b_idx])
    comment = String.new(comment_bytes[0..c_idx])

    if comment_bytes[28] == NULL_BYTE && comment_bytes[29] != NULL_BYTE
      version = 1
      track = comment_bytes[29].to_s
    end

    Tag.new(version, title, artist, album, year, comment, track, genre)
  end

  class Tag
    getter version : Int32
    getter title : String
    getter artist : String
    getter album : String
    getter year : String
    getter comment : String
    getter track : String?
    getter genre : Genre

    def initialize(@version, @title, @artist, @album, @year, @comment, @track, @genre)
    end
  end
end
