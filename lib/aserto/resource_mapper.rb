# frozen_string_literal: true

module Aserto
  module ResourceMapper
    class << self
      def execute(request)
        if defined? ::Rails
          params = request.params
          return {} unless params.is_a?(Hash) && !params.empty?

          require_relative "rails/utils"

          route = Aserto::Rails::Utils.route(request)
          path = route[:path] if route
          return {} unless path

          fields = path.split("/")
                       .select { |part| part.starts_with?(":") }
                       .map { |field| field.sub(":", "") }
          return {} if fields.empty?

          require "google/protobuf/well_known_types"
          return Google::Protobuf::Struct.from_hash(fields.to_h { |field| [field, params[field]] })

        end

        {}
      end
    end
  end
end
