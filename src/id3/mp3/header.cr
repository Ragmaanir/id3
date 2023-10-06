class Mp3::Frame::Header
  enum MPEGVersion
    V2_5 = 0b00
    V2   = 0b10
    V1   = 0b11
  end

  enum Layer
    L3 = 0b01
    L2 = 0b10
    L1 = 0b11

    def slot_size : BinarySize
      self == L1 ? 4.bytes : 1.bytes
    end
  end

  SAMPLES_PER_FRAME = {
    MPEGVersion::V1   => {Layer::L1 => 384, Layer::L2 => 1152, Layer::L3 => 1152},
    MPEGVersion::V2   => {Layer::L1 => 384, Layer::L2 => 1152, Layer::L3 => 576},
    MPEGVersion::V2_5 => {Layer::L1 => 384, Layer::L2 => 1152, Layer::L3 => 576},
  }

  SAMPLE_RATE = {
    MPEGVersion::V1   => [44100, 48000, 32000],
    MPEGVersion::V2   => [22050, 24000, 16000],
    MPEGVersion::V2_5 => [11025, 12000, 8000],
  }

  # V2/2.5
  COMMON_BITRATES = {
    Layer::L1 => [0, 32, 48, 56, 64, 80, 96, 112, 128, 144, 160, 176, 192, 224, 256].map(&.kbit),
    Layer::L2 => [0, 8, 16, 24, 32, 40, 48, 56, 64, 80, 96, 112, 128, 144, 160].map(&.kbit),
    Layer::L3 => [0, 8, 16, 24, 32, 40, 48, 56, 64, 80, 96, 112, 128, 144, 160].map(&.kbit),
  }

  # Bitrates are in kilo-bits / second
  BITRATE_MAP = {
    MPEGVersion::V1 => {
      Layer::L1 => [0, 32, 64, 96, 128, 160, 192, 224, 256, 288, 320, 352, 384, 416, 448].map(&.kbit),
      Layer::L2 => [0, 32, 48, 56, 64, 80, 96, 112, 128, 160, 192, 224, 256, 320, 384].map(&.kbit),
      Layer::L3 => [0, 32, 40, 48, 56, 64, 80, 96, 112, 128, 160, 192, 224, 256, 320].map(&.kbit),
    },
    MPEGVersion::V2   => COMMON_BITRATES,
    MPEGVersion::V2_5 => COMMON_BITRATES,
  }

  enum ChannelMode
    STEREO       = 0b00
    JOINT_STEREO = 0b01
    DUAL         = 0b10
    MONO         = 0b11
  end

  BITMAP = {
    sync:                21..31,
    version_bits:        19..20,
    layer_bits:          17..18,
    crc:                 16,
    bitrate_idx:         12..15,
    sampling_idx:        10..11,
    padding_bit:         9,
    reserved:            8,
    channel_mode_bits:   6..7,
    mode_extension_bits: 4..5,
    copyright:           3,
    original:            2,
    emphasis:            0..1,
  }

  {% for k, v in BITMAP %}
    def {{k.id}}
      {% if v.is_a?(NumberLiteral) %}
        @raw.bit({{v}})
      {% else %}
        @raw.bits({{v}})
      {% end %}
    end
  {% end %}

  getter raw : UInt32

  delegate slot_size, to: layer

  def initialize(@raw)
  end

  def valid?
    sync == 0b11111111111 &&
      version_bits != 0b01 &&
      layer_bits != 0b00 &&
      bitrate_idx != 0b1111 &&
      # FIXME: "free" bitrate (0b0000)?
      sampling_idx != 0b11
    # FIXME: check bitrate/mode combinations in MPEG1
  end

  def version
    MPEGVersion.from_value(version_bits)
  end

  def layer
    Layer.from_value(layer_bits)
  end

  def channel_mode
    ChannelMode.from_value(channel_mode_bits)
  end

  def sampling_rate
    SAMPLE_RATE[version][sampling_idx]
  end

  def bitrate : BinarySize
    BITRATE_MAP[version][layer][bitrate_idx]
  end

  def samples_per_frame
    SAMPLES_PER_FRAME[version][layer]
  end

  def padding : BinarySize
    # FIXME: confirm whether paddings is actually conceptually equal to the slot size
    padding_bit == 1 ? slot_size : 0.bytes
  end

  def frame_size : BinarySize
    (samples_per_frame / sampling_rate * bitrate.as_bytes).to_i.bytes + padding
  end

  def sample_duration
    (1 / sampling_rate).seconds
  end

  def frame_duration
    sample_duration * samples_per_frame
  end

  def mono?
    channel_mode.mono?
  end

  # def mode_extension
  #   nil # TODO: impl
  # end

  # def side_information : BinarySize
  #   if layer == Layer::L3
  #     if version == MPEGVersion::V1
  #       mono? ? 17.bytes : 32.bytes
  #     else
  #       mono? ? 9.bytes : 17.bytes
  #     end
  #   else
  #     raise "TODO" # TODO: implement
  #   end
  # end

  def xing_header_offset : BinarySize
    case version
    when MPEGVersion::V1
      mono? ? 21.bytes : 36.bytes
    when MPEGVersion::V2
      mono? ? 13.bytes : 21.bytes
    else Id3.bug!
    end
  end

  def to_s(io)
    io.puts "Mp3 Header (#{@raw.to_s(16)})"

    {
      sync:           sync,
      version:        version,
      layer:          layer,
      crc:            crc,
      bitrate:        bitrate,
      sampling_rate:  sampling_rate,
      padding:        padding,
      reserved:       reserved,
      channel_mode:   channel_mode,
      mode_extension: mode_extension_bits,
      copyright:      copyright,
      original:       original,
      emphasis:       emphasis,
      valid:          valid?,
    }.each { |k, v|
      io.print("%-20s" % k)
      io.print ": "
      io.puts v
    }
  end
end
