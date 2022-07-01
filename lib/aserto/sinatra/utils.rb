# frozen_string_literal: true

module Aserto
  module Sinatra
    module Utils
      class << self
        # Finds the Sinatra route for the given path.
        # If the route is not found, returns nil.
        # If the route is found, returns a hash with the following keys:
        # :path
        # :action
        #
        # Eg:
        # route("/api/v1/users/1") => {
        #   :action => :GET,
        #   :path => "/api/v1/users/:id" }
        def route(request)
          return unless defined? ::Sinatra

          path = request.path_info
          routes = ::Sinatra::Application.routes[request.request_method].map do |route|
            route.flatten.first
          end
          route = routes.find do |r|
            r.match(path)
          end

          return unless route

          substitutions = route.match(path).named_captures
          unless substitutions&.any?
            return {
              path: route.to_s,
              action: request.request_method.to_sym
            }
          end

          substitutions.each_pair do |sub, val|
            path.sub!(val, ":#{sub}")
          end
          {
            path: path,
            action: request.request_method.to_sym
          }
        end
      end
    end
  end
end
