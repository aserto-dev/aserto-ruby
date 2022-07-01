# frozen_string_literal: true

module Aserto
  class Authorization
    attr_reader :config

    def initialize(app, options = {})
      @app = app
      @config = Aserto.config(options)
      yield @config if block_given?
    end

    def call(env)
      request = Rack::Request.new(env)

      allowed = if enabled?(request)
                  Aserto.logger.debug("Aserto authorization enabled")
                  client = Aserto::AuthClient.new(request)
                  client.is
                else
                  Aserto.logger.debug("Aserto authorization not enabled")
                  true
                end

      if allowed
        status, headers, body = @app.call env
      else
        status = 403
        body = [{ message: "not allowed by aserto" }.to_json]
        headers = {}
      end

      [status, headers.merge({ "aserto-grpc-authz" => ::Aserto::Grpc::Authz::VERSION }), body]
    end

    private

    def route(request)
      @route ||= if defined? ::Rails
                   require "aserto/rails/utils"

                   Aserto::Rails::Utils.route(request)
                 elsif defined? ::Sinatra
                   require "aserto/sinatra/utils"
                   Aserto::Sinatra::Utils.route(request)
                 end
    end

    def enabled?(request)
      route_info = route(request)
      if route_info
        config.enabled && config.disabled_for.none? do |hash|
          hash[:path] == route_info[:path] && hash[:actions].include?(route_info[:action])
        end
      else
        config.enabled
      end
    end
  end
end
