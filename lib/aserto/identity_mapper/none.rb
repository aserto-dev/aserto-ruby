# frozen_string_literal: true

module Aserto
  module IdentityMapper
    module None
      extend Aserto::IdentityMapper::Base

      class << self
        def execute(_request)
          {
            type: INTERNAL_MAPPING[:none],
            identity: "null"
          }
        end
      end
    end
  end
end
