# frozen_string_literal: true

require_relative "../interceptors/headers"

module Aserto
  module Directory
    module V3
      class Config
        attr_reader :reader, :writer, :importer, :exporter, :model

        def initialize(config)
          @base = {
            url: config[:url],
            api_key: config[:api_key],
            tenant_id: config[:tenant_id],
            cert_path: config[:cert_path]
          }

          @reader = build(**(config[:reader] || {}))
          @writer = build(**(config[:writer] || {}))
          @importer = build(**(config[:importer] || {}))
          @exporter = build(**(config[:exporter] || {}))
          @model = build(**(config[:model] || {}))
        end

        private

        class BaseConfig
          attr_reader :url, :credentials, :interceptors

          DEFAULT_DIRECTORY_URL = "directory.prod.aserto.com:8443"

          def initialize(url, credentials, interceptors)
            @url = url
            @credentials = credentials
            @interceptors = interceptors
          end
        end

        def build(url: nil, api_key: @base[:api_key], tenant_id: @base[:tenant_id], cert_path: @base[:cert_path])
          return unless valid_config?(@base, { url: url, api_key: api_key, tenant_id: tenant_id })

          interceptors = [Interceptors::Headers.new(api_key, tenant_id)] if !api_key.nil? && !tenant_id.nil?
          BaseConfig.new(
            url || @base[:url] || BaseConfig::DEFAULT_DIRECTORY_URL,
            load_creds(cert_path),
            interceptors || []
          )
        end

        def valid_config?(config, fallback)
          !(config[:url].nil? && fallback[:url].nil?) ||
            ((!config[:api_key].nil? || !fallback[:api_key].nil?) &&
            (!config[:tenant_id].nil? || !fallback[:tenant_id].nil?))
        end

        def load_creds(cert_path)
          if cert_path && File.file?(cert_path)
            GRPC::Core::ChannelCredentials.new(File.read(cert_path))
          else
            GRPC::Core::ChannelCredentials.new
          end
        end
      end
    end
  end
end
