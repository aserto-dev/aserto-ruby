# frozen_string_literal: true

require "bundler/setup"
require "rspec"
require "grpc_mock/rspec"
require "rack"

require "aserto"
require "google/protobuf/well_known_types"

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

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

# configure Aserto
Aserto.configure do |config|
  config.policy_id = "1234"
  config.tenant_id = "12345"
  config.authorizer_api_key = "123456"
  config.policy_root = "peoplefinder"
  config.service_url = "authorizer.eng.aserto.com:8443"
  config.decision = "allowed"
end
