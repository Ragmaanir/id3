require "../spec_helper"

describe Mp3::Frame do
  include Mp3

  test "header.valid?" do
    h = Frame::Header.new(0x10000000)

    assert !h.valid?
    assert h.sync == 0b00010000000
  end

  test "find_first_frame"
end
