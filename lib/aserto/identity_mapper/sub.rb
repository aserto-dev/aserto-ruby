# frozen_string_literal: true

module Aserto
  module IdentityMapper
    module Sub
      extend Aserto::IdentityMapper::Base

      class << self
        def execute(request)
          config = Aserto.config
          auth_token = request.get_header("HTTP_AUTHORIZATION")
          return {} unless auth_token

          auth_token = auth_token.split.last if auth_token
          data = extract_data(auth_token) || {}

          {
            type: INTERNAL_MAPPING[:sub],
            identity: data[config.identity_mapping[:from].to_s]
          }
        end
      end
    end
  end
end
