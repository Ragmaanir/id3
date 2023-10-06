require "../spec_helper"

describe Id3::V2::Frame do
  include Id3::V2

  test "Encoding.split_by_terminator with utf16" do
    slice = Bytes[
      # BOM + NULL
      0xff, 0xfe, 0x00, 0x00,
      # BOM + "Visit"
      0xff, 0xfe, 0x56, 0x00, 0x69, 0x00, 0x73, 0x00, 0x69, 0x00, 0x74, 0x00,
    ]

    enc = Frame::Encoding::UTF_16
    slices = enc.split_by_terminator(slice)

    assert slices == [Bytes[0xff, 0xfe], Bytes[0xff, 0xfe, 0x56, 0x00, 0x69, 0x00, 0x73, 0x00, 0x69, 0x00, 0x74, 0x00]]
  end

  test "Encoding.split_by_terminator with utf8" do
    slice = Bytes[
      0x00,
      0x56, 0x69, 0x73, 0x69, 0x74,
    ]

    enc = Frame::Encoding::UTF_8
    slices = enc.split_by_terminator(slice)

    assert slices == [Bytes[], Bytes[0x56, 0x69, 0x73, 0x69, 0x74]]
  end

  test "Encoding.split_by_terminator with utf8 and no terminator" do
    slice = Bytes[0x49]

    enc = Frame::Encoding::UTF_8
    slices = enc.split_by_terminator(slice)

    assert slices.size == 1

    assert slices == [Bytes[0x49]]
  end

  test "Encoding.split_by_terminator with utf8 and just a terminator" do
    slice = Bytes[0x00]

    enc = Frame::Encoding::UTF_8
    slices = enc.split_by_terminator(slice)

    assert slices == [Bytes[], Bytes[]]
  end
end
