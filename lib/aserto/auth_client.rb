# frozen_string_literal: true

require "aserto-grpc-authz"

require_relative "identity_mapper"
require_relative "policy_path_mapper"
require_relative "resource_mapper"

module Aserto
  class AuthClient
    attr_reader :client, :config, :request

    INTERNAL_MAPPING = {
      unknown: Aserto::Api::V1::IdentityType::IDENTITY_TYPE_UNKNOWN,
      none: Aserto::Api::V1::IdentityType::IDENTITY_TYPE_NONE,
      sub: Aserto::Api::V1::IdentityType::IDENTITY_TYPE_SUB,
      jwt: Aserto::Api::V1::IdentityType::IDENTITY_TYPE_JWT
    }.freeze

    private_constant :INTERNAL_MAPPING

    def initialize(request)
      @request = request
      @config = Aserto.config
      @client = Aserto::Authorizer::Authorizer::V1::Authorizer::Stub.new(
        config.service_url,
        GRPC::Core::ChannelCredentials.new
      )
    end

    def is
      exec_is(config.decision)
    end

    def allowed?
      exec_is("allowed")
    end

    def visible?
      exec_is("visible")
    end

    def enabled?
      exec_is("enabled")
    end

    private

    def exec_is(decision)
      begin
        response = client.is(
          request_is(decision), { metadata: {
            "aserto-tenant-id": config.tenant_id,
            authorization: "basic #{config.authorizer_api_key}"
          } }
        )
      rescue GRPC::BadStatus => e
        Aserto.logger.error(e.inspect)
        return false
      end

      decision = response.decisions.find { |el| el.decision == decision }
      return false unless decision

      decision.is
    end

    def request_is(decision)
      Aserto::Authorizer::Authorizer::V1::IsRequest.new(
        {
          policy_context: policy_context(decision),
          identity_context: identity_context,
          resource_context: resource_context
        }
      )
    end

    def policy_context(decision)
      path = Aserto::PolicyPathMapper.execute(config.policy_root, request)
      Aserto.logger.debug "aserto authorizing: #{path}"

      Aserto::Api::V1::PolicyContext.new(
        {
          id: config.policy_id,
          path: path,
          decisions: [decision]
        }
      )
    end

    def identity_context
      identity = Aserto::IdentityMapper.execute(request)
      Aserto::Api::V1::IdentityContext.new(
        {
          identity: identity.fetch(:identity, "null"),
          type: INTERNAL_MAPPING[identity.fetch(:type, :unknown)]
        }
      )
    end

    def resource_context
      ResourceMapper.execute(request)
    end
  end
end
