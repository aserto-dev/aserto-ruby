# frozen_string_literal: true

module Aserto
  module Rails
    module Utils
      class << self
        # Finds the Rails route for the given path.
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
          return unless defined? ::Rails

          path = request.path_info
          route = ::Rails.application.routes.routes.to_a.find do |cr|
            cr.path.to_regexp.match?(path)
          end

          return unless route

          {
            path: route.path.spec.to_s.sub("(.:format)", ""),
            action: request.request_method.to_sym
          }
        end
      end
    end
  end
end
