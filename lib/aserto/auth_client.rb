# frozen_string_literal: true

require "aserto-grpc-authz"

module Aserto
  class AuthClient
    attr_reader :client, :config, :request

    INTERNAL_MAPPING = {
      unknown: ::Aserto::Api::V1::IdentityType::IDENTITY_TYPE_UNKNOWN,
      none: ::Aserto::Api::V1::IdentityType::IDENTITY_TYPE_NONE,
      sub: ::Aserto::Api::V1::IdentityType::IDENTITY_TYPE_SUB,
      jwt: ::Aserto::Api::V1::IdentityType::IDENTITY_TYPE_JWT
    }.freeze

    private_constant :INTERNAL_MAPPING

    def initialize(request)
      @request = request
      @config = Aserto.config
      @client = Aserto::Authorizer::Authorizer::V1::Authorizer::Stub.new(
        config.authorizer_url,
        GRPC::Core::ChannelCredentials.new
      )
    end

    def is
      is_request = Aserto::Authorizer::Authorizer::V1::IsRequest.new(
        {
          policy_context: policy_context,
          identity_context: identity_context,
          resource_context: resource_context
        }
      )

      begin
        response = client.is(
          is_request, { metadata: {
            "aserto-tenant-id": config.tenant_id,
            authorization: "basic #{config.authorizer_api_key}"
          } }
        )
      rescue GRPC::BadStatus
        false
      end
      allowed = response.to_h.dig(:decisions, 0, :is) || false
      Aserto.logger.debug "ALLOWED: #{allowed}"
      allowed
    end

    private

    def policy_context
      path = PolicyPathMapper.execute(config.policy_root, request)
      Aserto.logger.debug PATH: path
      Aserto::Api::V1::PolicyContext.new(
        {
          id: config.policy_id,
          path: path,
          decisions: [config.decision]
        }
      )
    end

    def identity_context
      identity = IdentityMapper.execute(request)
      puts ID: identity
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
