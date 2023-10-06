require "log"

require "./id3/binary_size"
require "./id3/synchsafe_int"
require "./id3/reader"
require "./id3/unsynchronization_scheme"
require "./id3/v1"
require "./id3/v2"
require "./id3/tagged_file"
require "./id3/mp3"

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
end
