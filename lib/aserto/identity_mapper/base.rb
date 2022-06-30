# frozen_string_literal: true

module Aserto
  module IdentityMapper
    module Base
      INTERNAL_MAPPING = {
        unknown: ::Aserto::Api::V1::IdentityType::IDENTITY_TYPE_UNKNOWN,
        none: ::Aserto::Api::V1::IdentityType::IDENTITY_TYPE_NONE,
        sub: ::Aserto::Api::V1::IdentityType::IDENTITY_TYPE_SUB,
        jwt: ::Aserto::Api::V1::IdentityType::IDENTITY_TYPE_JWT
      }.freeze

      private_constant :INTERNAL_MAPPING

      def extract_data(token)
        require "jwt"

        ((JWT.decode token, nil, false) || [])[0]
      rescue StandardError
        Aserto.logger.error("Invalid auth token")
        nil
      end

      def valid?(token)
        require "jwt"

        return false unless token

        begin
          JWT.decode token, nil, false
          true
        rescue StandardError
          false
        end
      end
    end
  end
end
