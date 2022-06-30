# frozen_string_literal: true

module Aserto
  module Rails
    module Utils
      class << self
        # Finds the Rails route for the given path.
        # If the route is not found, returns nil.
        # If the route is found, returns a hash with the following keys:
        # :controller
        # :action
        # :path
        #
        # Eg:
        # route("/api/v1/users/1") => {
        #   :controller => "api/v1/users",
        #   :action => "show",
        #   :path => "/api/v1/users/:id" }
        def route(path)
          return unless defined? ::Rails

          route = ::Rails.application.routes.routes.to_a.find do |cr|
            cr.path.to_regexp.match?(path)
          end

          return unless route

          {
            path: route.path.spec.to_s.sub("(.:format)", ""),
            controller: route.defaults[:controller],
            action: route.defaults[:action]
          }
        end
      end
    end
  end
end
