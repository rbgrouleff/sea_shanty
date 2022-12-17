# frozen_string_literal: true

require_relative "lib/sea_shanty/version"

Gem::Specification.new do |spec|
  spec.name = "sea_shanty"
  spec.version = SeaShanty::VERSION
  spec.authors = ["Rasmus Bang Grouleff"]
  spec.email = ["rasmus@nerdd.dk"]

  spec.summary = "SeaShanty records HTTP requests and responses and returns saved responses for requests it has seen before."
  spec.description = "SeaShanty is a minimalistic library for recording HTTP requests and responses and replaying responses for already seen requests in an unobtrusive and test framework agnostic way."
  spec.homepage = "https://github.com/rbgrouleff/sea_shanty"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = [spec.homepage, "CHANGELOG.md"].join("/")

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
