# frozen_string_literal: true

module Aserto
  module IdentityMapper
    module Jwt
      extend Aserto::IdentityMapper::Base

      class << self
        def execute(request)
          config = Aserto.config
          auth_token = request.get_header(
            config.identity_mapping[:from] || "HTTP_AUTHORIZATION"
          )
          return {} unless valid?(auth_token)

          {
            type: :jwt,
            identity: auth_token
          }
        end
      end
    end
  end
end
