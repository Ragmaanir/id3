require "log"

require "./id3/synchsafe_int"
require "./id3/reader"
require "./id3/unsynchronization_scheme"
require "./id3/v1"
require "./id3/v2"

module Id3
  ROOT    = Path.new(__DIR__).parent
  VERSION = {{ `shards version #{__DIR__}`.strip.stringify }}

  NULL_BYTE = 0_u8

  Log = ::Log.for(self)

  def self.bug!(msg : String = "An internal error occurred, please report!")
    raise "BUG: #{msg}"
  end

  class ValidationException < Exception
  end

  class TaggedFile
    def self.read(p : Path)
      read(Reader.new(File.new(p)))
    end

    def self.read(f : File)
      read(Reader.new(f))
    end

    def self.read(r : Reader)
      v1 = V1.read(r) if V1.present?(r)
      r.seek(0)
      v2 = V2.read(r) if V2.present?(r)

      TaggedFile.new(v1, v2)
    end

    getter v1 : V1::Tag?
    getter v2 : V2::Tag?

    def initialize(@v1, @v2)
    end

    SHORTCUTS = ["title", "artist", "album", "track", "year", "genre"]

    {% for m in SHORTCUTS %}
      def {{m.id}}
        v2.try(&.{{m.id}}) || v1.try(&.{{m.id}})
      end
    {% end %}
  end
end
