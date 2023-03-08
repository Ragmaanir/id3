require "./spec_helper"

describe Id3::UnsynchronizationScheme do
  include Id3

  delegate apply, unapply, to: UnsynchronizationScheme

  def apply(str : String)
    String.new(apply(str.to_slice))
  end

  def unapply(str : String)
    String.new(unapply(str.to_slice))
  end

  def assert_reversible?(input)
    assert unapply(apply(input)) == input
  end

  test "apply" do
    assert apply("") == ""
    assert apply("\x00") == "\x00"
    assert apply("\xFF") == "\xFF"
    assert apply("\x00\x00") == "\x00\x00"

    # escaping SYNC
    assert apply("\xFF\xFF") == "\xFF\x00\xFF"
    assert apply("\xFF\xE5") == "\xFF\x00\xE5"
    # NOT escaping SYNC (edge case)
    assert apply("\xFF\xD5") == "\xFF\xD5"

    # escaping NULL_BYTE sequence
    assert apply("\xFF\x00") == "\xFF\x00\x00"
    assert apply("\xFF\x00\x00") == "\xFF\x00\x00\x00"

    # combination
    assert apply("\xFF\x00\xFF\xE5") == "\xFF\x00\x00\xFF\x00\xE5"

    # random string
    str = "this is a safe string because it does not contain sync-bytes\n"
    assert apply(str) == str
  end

  test "unapply" do
    assert_reversible?("\x00")
    assert_reversible?("\xFF")

    # escaping SYNC
    assert_reversible?("\xFF\xFF")
    assert_reversible?("\xFF\xE5")
    # NOT escaping SYNC (edge case)
    assert_reversible?("\xFF\xD5")

    # escaping NULL_BYTE sequence
    assert_reversible?("\xFF\x00")
    assert_reversible?("\xFF\x00\x00")

    # combination
    assert_reversible?("\xFF\x00\xFF\xE5")

    # random string
    str = "this is a safe string because it does not contain sync-bytes\n"
    assert_reversible?(str)
  end
end
