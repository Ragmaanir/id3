module Mp3
  alias Reader = Id3::Reader
end

require "./ogg"
require "./mp3/frame"
require "./mp3/meta"
require "./mp3/header"
require "./mp3/xing_header"
