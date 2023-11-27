# frozen_string_literal: true

module Aserto
  module IdentityMapper
    module Manual
      class << self
        def execute(_request)
          {
            type: :manual,
            identity: ::Aserto.config.identity_mapping[:value].to_s
          }
        end
      end
    end
  end
end
