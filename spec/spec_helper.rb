# frozen_string_literal: true

require "bundler/setup"
require "rspec"
require "grpc_mock/rspec"
require "rack"

require "aserto"
require "google/protobuf/well_known_types"
require_relative "integration/topaz"

require "simplecov"
SimpleCov.start do
  enable_coverage :branch
  track_files "lib/**/*.rb"
end

GrpcMock.disable_net_connect!

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expose_dsl_globally = true

  # integration tests setup
  config.before(:all, type: :integration) do
    GrpcMock.allow_net_connect!
    Topaz.run
  end

  config.after(:all, type: :integration) do
    GrpcMock.disable_net_connect!
    Topaz.cleanup
  end

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

# configure Aserto
Aserto.configure do |config|
  config.policy_name = "peoplefinder"
  config.authorizer_api_key = "123456"
  config.policy_root = "peoplefinder"
  config.instance_label = "peoplefinder"
  config.service_url = "localhost:8282"
  config.decision = "allowed"
end
