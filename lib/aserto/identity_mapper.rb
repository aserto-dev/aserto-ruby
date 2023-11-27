# frozen_string_literal: true

require_relative "identity_mapper/base"
require_relative "identity_mapper/none"
require_relative "identity_mapper/sub"
require_relative "identity_mapper/jwt"
require_relative "identity_mapper/manual"

module Aserto
  module IdentityMapper
    STRATEGY = {
      none: Aserto::IdentityMapper::None,
      manual: Aserto::IdentityMapper::Manual,
      sub: Aserto::IdentityMapper::Sub,
      jwt: Aserto::IdentityMapper::Jwt
    }.freeze

    class << self
      def execute(request)
        STRATEGY.fetch(
          Aserto.config.identity_mapping[:type].to_sym || :none,
          Aserto::IdentityMapper::None
        ).execute(request)
      end
    end
  end
end
