# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "aserto"
  spec.version       = File.read(File.join(__dir__, "VERSION")).chomp
  spec.authors       = ["Aserto"]
  spec.email         = ["aserto@aserto.com"]

  spec.summary       = "Aserto Middleware"
  spec.description   = "Aserto Middleware"
  spec.homepage      = "https://www.aserto.com"
  spec.license       = "Apache-2.0"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.7.0")

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/aserto-dev/aserto-ruby"
  spec.metadata["changelog_uri"] = "https://github.com/aserto-dev/aserto-ruby"
  spec.metadata["documentation_uri"] = "https://docs.aserto.com/docs/software-development-kits/ruby/middleware"

  dirs =
    Dir[File.join(__dir__, "README.md")] +
    Dir[File.join(__dir__, "CHANGELOG.md")] +
    Dir[File.join(__dir__, "LICENSE")] +
    Dir[File.join(__dir__, "VERSION")] +
    Dir[File.join(__dir__, "lib/**/*.rb")]
  spec.files = dirs.map { |path| path.sub("#{__dir__}#{File::SEPARATOR}", "") }

  spec.require_paths = %w[lib]
  spec.metadata["rubygems_mfa_required"] = "true"

  # runtime dependencies
  spec.add_runtime_dependency "aserto-grpc-authz", "~> 0.0.6"
  spec.add_runtime_dependency "jwt", "~> 2.4"
  spec.add_runtime_dependency "rack", "~> 2.0"

  # development dependencies
  spec.add_development_dependency("bundler", ">= 1.15.0", "< 3.0")
  spec.add_development_dependency "codecov", "~> 0.6"
  spec.add_development_dependency "grpc_mock", "~> 0.4"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop-performance", "~> 1.14"
  spec.add_development_dependency "rubocop-rspec", "~> 2.11"
end
