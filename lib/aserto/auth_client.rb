# frozen_string_literal: true

require "aserto/authorizer"

require_relative "identity_mapper"
require_relative "policy_path_mapper"
require_relative "resource_mapper"

module Aserto
  class AuthClient
    attr_reader :client, :config, :request

    INTERNAL_MAPPING = {
      unknown: Aserto::Authorizer::V2::Api::IdentityType::IDENTITY_TYPE_UNKNOWN,
      none: Aserto::Authorizer::V2::Api::IdentityType::IDENTITY_TYPE_NONE,
      sub: Aserto::Authorizer::V2::Api::IdentityType::IDENTITY_TYPE_SUB,
      jwt: Aserto::Authorizer::V2::Api::IdentityType::IDENTITY_TYPE_JWT
    }.freeze

    private_constant :INTERNAL_MAPPING

    def initialize(request)
      @request = request
      @config = Aserto.config
      @client = Aserto::Authorizer::V2::Authorizer::Stub.new(
        config.service_url,
        load_creds
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

    def load_creds
      cert_path = config.cert_path
      if cert_path && File.file?(cert_path)
        GRPC::Core::ChannelCredentials.new(File.read(cert_path))
      else
        GRPC::Core::ChannelCredentials.new
      end
    end

    def exec_is(decision)
      begin
        response = client.is(request_is(decision), headers)
      rescue GRPC::BadStatus => e
        Aserto.logger.error(e.inspect)
        return false
      end

      decision = response.decisions.find { |el| el.decision == decision }
      return false unless decision

      decision.is
    end

    def headers
      headers = {
        authorization: "basic #{config.authorizer_api_key}"
      }

      headers["aserto-tenant-id"] = config.tenant_id if config.tenant_id && config.tenant_id != ""

      { metadata: headers }
    end

    def request_is(decision)
      Aserto::Authorizer::V2::IsRequest.new(
        {
          policy_context: policy_context(decision),
          policy_instance: policy_instance,
          identity_context: identity_context,
          resource_context: resource_context
        }
      )
    end

    def policy_instance
      return unless config.policy_name && config.instance_label

      Aserto::Authorizer::V2::Api::PolicyInstance.new(
        {
          name: config.policy_name,
          instance_label: config.instance_label
        }
      )
    end

    def policy_context(decision)
      path = Aserto::PolicyPathMapper.execute(config.policy_root, request)
      Aserto.logger.debug "aserto authorizing: #{path}"

      Aserto::Authorizer::V2::Api::PolicyContext.new(
        {
          path: path,
          decisions: [decision]
        }
      )
    end

    def identity_context
      identity = Aserto::IdentityMapper.execute(request)
      Aserto::Authorizer::V2::Api::IdentityContext.new(
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
