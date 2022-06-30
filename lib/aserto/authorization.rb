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
                  Aserto.logger.debug("Authorization enabled")
                  client = AuthClient.new(request)
                  client.is
                else
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

    def enabled?(request)
      if defined? ::Rails
        require "aserto/rails/utils"

        path = Rails::Utils.route(request.path_info)

        config.enabled && config.disabled_for.none? do |hash|
          hash[:controller] == path[:controller] && hash[:actions].include?(path[:action].to_sym)
        end
      else
        config.enabled
      end
    end
  end
end
