# frozen_string_literal: true

require "aserto/identity_mapper/base"
require "aserto/identity_mapper/none"
require "aserto/identity_mapper/sub"
require "aserto/identity_mapper/jwt"

module Aserto
  module IdentityMapper
    STRATEGY = {
      none: Aserto::IdentityMapper::None,
      sub: Aserto::IdentityMapper::Sub,
      jwt: Aserto::IdentityMapper::Jwt
    }.freeze

    private_constant :STRATEGY

    class << self
      def execute(request)
        STRATEGY[
          Aserto.config.identity_mapping[:type].to_sym || :none
        ].execute(request)
      end
    end
  end
end
