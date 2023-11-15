# frozen_string_literal: true

require_relative "../interceptors/headers"

module Aserto
  module Directory
    module V3
      class Config
        attr_reader :reader, :writer, :importer, :exporter, :model

        def initialize(config)
          @base = {
            url: config[:url] || "directory.prod.aserto.com:8443",
            api_key: config[:api_key],
            tenant_id: config[:tenant_id]
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

          def initialize(url, credentials, interceptors)
            @url = url
            @credentials = credentials
            @interceptors = interceptors
          end
        end

        def build(url: @base[:url], api_key: @base[:api_key], tenant_id: @base[:tenant_id], cert_path: nil)
          return if url.nil? || url.empty? || api_key.nil? || api_key.empty? || tenant_id.nil? || tenant_id.empty?

          BaseConfig.new(url, load_creds(cert_path), [Interceptors::Headers.new(api_key, tenant_id)])
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
