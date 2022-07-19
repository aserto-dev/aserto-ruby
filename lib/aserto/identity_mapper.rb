# frozen_string_literal: true

require_relative "identity_mapper/base"
require_relative "identity_mapper/none"
require_relative "identity_mapper/sub"
require_relative "identity_mapper/jwt"

module Aserto
  module IdentityMapper
    STRATEGY = {
      none: Aserto::IdentityMapper::None,
      sub: Aserto::IdentityMapper::Sub,
      jwt: Aserto::IdentityMapper::Jwt
    }.freeze

    class << self
      def execute(request)
        STRATEGY[
          Aserto.config.identity_mapping[:type].to_sym || :none
        ].execute(request)
      end
    end
  end
end
