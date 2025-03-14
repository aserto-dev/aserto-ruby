# frozen_string_literal: true

module Aserto
  module PolicyPathMapper
    class << self
      def execute(policy_root, request)
        method = request.request_method
        path = request.path_info

        if defined? ::Rails
          require_relative "rails/utils"

          route = Aserto::Rails::Utils.route(request)
          path = route[:path] if route
        end

        if defined? ::Sinatra
          require_relative "sinatra/utils"

          route = Aserto::Sinatra::Utils.route(request)
          path = route[:path] if route
        end

        policy_path = "#{policy_root}.#{method}.#{path}"
        policy_path.tr!("/", ".")
        policy_path.gsub!("..", ".")
        policy_path.gsub!(":", "__")
        policy_path.gsub!(/[^a-zA-Z0-9._]/, "_")
        policy_path.chomp!(".")
        policy_path
      end
    end
  end
end
