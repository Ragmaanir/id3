require "ecr"
require "kommando"

class Id3::Cli::Readme
  include Kommando::Command

  def self.description
    "Generate README.md from README.md.ecr"
  end

  class ReadmeTemplate
    ECR.def_to_s "README.md.ecr"
  end

  def call
    puts "Building README.md from README.md.ecr"
    File.write(ROOT / "README.md", ReadmeTemplate.new.to_s)
  end
end
