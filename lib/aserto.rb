# frozen_string_literal: true

require "rack"
require "aserto/authorizer"

require_relative "aserto/version"
require_relative "aserto/config"
require_relative "aserto/authorization"
require_relative "aserto/policy_path_mapper"
require_relative "aserto/identity_mapper"
require_relative "aserto/resource_mapper"
require_relative "aserto/auth_client"
require_relative "aserto/errors"

module Aserto
  class << self
    def config(options = {})
      @config ||= Config.new(options)
    end

    def logger
      config.logger
    end

    def configure
      yield config
    end

    # Allows the initializer to provide a custom
    # implementation for the PolicyPathMapper
    #
    # Aserto.with_policy_path_mapper do |request|
    #   method = request.request_method
    #   path = request.path_info
    #   "custom => #{method}.#{path}"
    # end
    def with_policy_path_mapper
      Aserto::PolicyPathMapper.class_eval do |klass|
        klass.define_singleton_method(:execute) do |request|
          yield(request) if block_given?
        end
      end
    end

    # Allows the initializer to provide a custom
    # implementation for the ResourceMapper
    #
    # Aserto.with_resource_mapper do |request|
    #   { resource:  request.path_info }
    # end
    def with_resource_mapper
      Aserto::ResourceMapper.class_eval do |klass|
        klass.define_singleton_method(:execute) do |request|
          if block_given?
            result = yield(request)
            unless result.is_a?(Hash)
              raise Aserto::InvalidResourceMapping, "block must return a hash, got: #{result.class}"
            end

            require "google/protobuf/well_known_types"

            result.transform_keys!(&:to_s)
            Google::Protobuf::Struct.from_hash(result)
          end
        end
      end
    end

    # Allows the initializer to provide a custom
    # implementation for the IdentityMapper
    #
    # Aserto.with_identity_mapper do |request|
    #   {
    #     sub: "test",
    #     type: :none
    #   }
    # end
    def with_identity_mapper
      Aserto::IdentityMapper.class_eval do |klass|
        klass.define_singleton_method(:execute) do |request|
          yield(request) if block_given?
        end
      end
    end
  end
end
