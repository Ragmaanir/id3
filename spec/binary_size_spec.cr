require "./spec_helper"

describe BinarySize do
  test "units" do
    assert 3.bytes
    assert 5.mb

    BinarySize.new(100)
  end

  # test "units" do
  #   assert 3.bits.bits?
  #   assert 3.bytes.bytes?
  #   assert 5.mb.mb?
  # end

  test "compare" do
    assert 1.bytes == 8.bits
    assert 1.kb == 8_000.bits
    assert 1.mb == 8_000_000.bits
    assert 1.gb == 8_000_000_000.bits
    assert 1.tb == 8_000_000_000_000.bits
  end

  test "maths" do
    assert (5.bits + 3.bits) == 1.bytes
    assert (2.bytes + 16.bits) == 4.bytes
  end

  test "byte_based?" do
    assert 0.bits.byte_based?
    assert 8.bits.byte_based?
    assert 32.bits.byte_based?

    assert 1.mb.byte_based?
    assert 1.mibit.byte_based?

    assert !1.bits.byte_based?
    assert !2.bits.byte_based?
    assert !7.bits.byte_based?
    assert !33.bits.byte_based?
  end

  # test "cannot add integers" do
  #   5 + 3.bits
  # end

  # test "conversion" do
  # end
end
