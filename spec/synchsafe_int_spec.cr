require "./spec_helper"

describe Id3::SynchsafeInt do
  delegate decode, to: SynchsafeInt

  test "decode" do
    assert decode(2345) == 1193
    assert decode(383) == 255
    assert decode(5) == 5
    assert decode(256) == 128
  end
end
