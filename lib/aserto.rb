# frozen_string_literal: true

require "rack"
require "aserto-grpc-authz"

require "aserto/version"
require "aserto/config"
require "aserto/authorization"
require "aserto/policy_path_mapper"
require "aserto/identity_mapper"
require "aserto/resource_mapper"
require "aserto/auth_client"

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
    # Aserto.with_policy_path_mapper do |policy_root, request|
    #   method = request.request_method
    #   path = request.path_info
    #   "custom => #{policy_root}.#{method}.#{path}"
    # end
    def with_policy_path_mapper
      Aserto::PolicyPathMapper.class_eval do |klass|
        klass.define_singleton_method(:execute) do |policy_root, request|
          yield(policy_root, request) if block_given?
        end
      end
    end

    # Allows the initializer to provide a custom
    # implementation for the ResourceMapper
    #
    # Aserto.with_resource_mapper do |request|
    #   "resource => #{request}"
    # end
    def with_resource_mapper
      Aserto::ResourceMapper.class_eval do |klass|
        klass.define_singleton_method(:execute) do |request|
          yield(request) if block_given?
        end
      end
    end

    # Allows the initializer to provide a custom
    # implementation for the IdentityMapper
    #
    # Aserto.with_identity_mapper do |request|
    #   {
    #     sub: "test",
    #     type: 1
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
