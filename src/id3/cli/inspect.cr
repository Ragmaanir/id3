require "colorize"
require "kommando"

class Id3::Cli::Inspect
  include Kommando::Command

  def self.description
    "Print ID3 metadata of a mp3 file"
  end

  arg :file, String

  def call
    tag = TaggedFile.read(Path[file])

    Printer.io(STDOUT, true) do |t|
      if v = tag.v1
        t.l("ID3 V1:", fg: :green)
        t.l "-"*10, fg: :dark_gray

        v.to_tuple.each do |k, v|
          t.w(k.to_s, ": ", fg: :cyan)
          t.l(v.to_s)
        end
        t.l "-"*10, fg: :dark_gray

        t.br
      end

      if v = tag.v2
        t.l("ID3 V2:", fg: :green)

        t.l "-"*10, fg: :dark_gray
        t.w "Version: ", fg: :cyan
        t.l v.header.version.to_s

        t.w "Flags: ", fg: :cyan
        t.l v.header.flags.to_s

        t.w "Size: ", fg: :cyan
        t.l v.header.tag_size.to_s
        t.l "-"*10, fg: :dark_gray

        v.frames.each do |f|
          t.w f.id, fg: :cyan
          t.w "[", f.size, ", ", f.flags.to_s, "]", fg: :light_gray
          case f
          when V2::TextFrame
            t.w ": "
            t.w f.content
          when V2::CommentFrame
            t.w ": ("
            t.w f.language
            t.w ") "
            t.w f.description
            t.w " => "
            t.w f.content
          end

          t.br
        end
        t.l "-"*10, fg: :dark_gray
      end
    end
  end
end

class Printer
  def self.string(colorize : Bool) : String
    String.build do |io|
      t = new(io, colorize)
      yield t
    end
  end

  def self.io(io : IO, colorize : Bool)
    t = new(io, colorize)
    yield t
    nil
  end

  getter io : IO
  getter? colorize

  def initialize(@io, @colorize : Bool = true)
  end

  private def colorized_io(fg : Symbol? = nil, bg : Symbol? = nil, m : Colorize::Mode? = nil)
    if colorize?
      c = Colorize.with
      c = c.fore(fg) if fg
      c = c.mode(m) if m
      c = c.back(bg) if bg

      c.surround(io) do |cio|
        yield cio
      end
    else
      yield io
    end
  end

  def w(*strs : String | Int32 | Nil, fg : Symbol? = nil, bg : Symbol? = nil, m : Colorize::Mode? = nil)
    colorized_io(fg, bg, m) do |cio|
      strs.each { |s| cio << s }
    end
  end

  def l(*args, **opts)
    w(*args, **opts)
    br
  end

  def br
    w("\n")
  end
end
