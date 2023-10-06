module Id3
  class TaggedFile
    def self.read(f : File | Path)
      read(Reader.new(f))
    end

    def self.read(r : Reader, fast = false)
      v2 = V2.read(r) if V2.present?(r)
      read_v1 = !fast || !v2 || !v2.basics?
      v1 = V1.read(r) if read_v1 && V1.present?(r)

      TaggedFile.new(v1, v2)
    end

    getter v1 : V1::Tag?
    getter v2 : V2::Tag?

    def initialize(@v1, @v2)
    end

    SHORTCUTS = ["title", "artist", "album", "track", "year", "genre", "comment"]

    {% for m in SHORTCUTS %}
      def {{m.id}}
        v2.try(&.{{m.id}}) || v1.try(&.{{m.id}})
      end
    {% end %}

    def pretty_print(pp : PrettyPrint)
      pp.text "TaggedFile".colorize(:cyan)

      pp.group(2, "(", ")") do
        pp.breakable("\n")
        v1.pretty_print(pp)
        pp.comma
        v2.pretty_print(pp)
      end
    end
  end
end
