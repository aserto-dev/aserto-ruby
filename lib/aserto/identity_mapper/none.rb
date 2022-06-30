# frozen_string_literal: true

module Aserto
  module IdentityMapper
    module None
      class << self
        def execute(_request)
          {
            type: :none,
            identity: "null"
          }
        end
      end
    end
  end
end
