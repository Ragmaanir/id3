require "./spec_helper"

describe Mp3::Readme do
  include Mp3

  test "mp3 example" do
    {{`cat spec/readme/mp3_example.cr`}}
  end

  test "tagged file example" do
    {{`cat spec/readme/tagged_file_example.cr`}}
  end
end
