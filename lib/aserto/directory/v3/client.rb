# frozen_string_literal: true

require "aserto/directory"
require_relative "../interceptors/headers"
require_relative "config"

module Aserto
  module Directory
    module V3
      class Client
        attr_reader :reader, :writer, :importer, :exporter, :model

        # Creates a new Directory V3 Client
        #
        # @param config [Aserto::Directory::V3::Config] the service configuration
        # Base configuration
        # If non-nil, this configuration is used for any client that doesn't have its own configuration.
        # If nil, only clients that have their own configuration will be created.
        # {
        #   url: "base_url",
        #   tenant_id: "base_tenant_id",
        #   api_key: "base_api_key"
        #
        #   Reader Configuration
        #   reader: {
        #     url: "reader_url",
        #     tenant_id: "reader_tenant_id",
        #     api_key: "reader_api_key"
        #   },
        #
        #   Writer Configuration
        #   writer: {
        #     url: "writer_url",
        #     tenant_id: "writer_tenant_id",
        #     api_key: "writer_api_key"
        #   },
        #
        #   Importer Configuration
        #   importer: {
        #     url: "importer_url",
        #     tenant_id: "importer_tenant_id",
        #     api_key: "importer_api_key"
        #   },
        #
        #   Exporter Configuration
        #   exporter: {
        #     url: "exporter_url",
        #     tenant_id: "exporter_tenant_id",
        #     api_key: "exporter_api_key"
        #   },
        #
        #   Model Configuration
        #   model: {
        #     url: "model_url",
        #     tenant_id: "model_tenant_id",
        #     api_key: "model_api_key"
        #   }
        # }
        #
        # @return [Aserto::Directory::V3::Client] the new Directory V3 Client
        def initialize(config)
          base_config = ::Aserto::Directory::V3::Config.new(config)

          @reader = create_client(:reader, base_config.reader)
          @writer = create_client(:writer, base_config.writer)
          @importer = create_client(:importer, base_config.importer)
          @exporter = create_client(:exporter, base_config.exporter)
          @model = create_client(:model, base_config.model)
        end

        private

        class NullClient
          def initialize(name)
            @name = name
          end

          def method_missing(method, *_args)
            puts "Cannot call '#{method}': '#{@name.to_s.capitalize}' client is not initialized."
          end

          def respond_to_missing?(_name, _include_private)
            true
          end
        end

        SERVICE_MAP = {
          reader: ::Aserto::Directory::Reader::V3::Reader::Stub,
          writer: ::Aserto::Directory::Writer::V3::Writer::Stub,
          importer: ::Aserto::Directory::Importer::V3::Importer::Stub,
          exporter: ::Aserto::Directory::Exporter::V3::Exporter::Stub,
          model: ::Aserto::Directory::Model::V3::Model::Stub
        }.freeze

        def create_client(type, config)
          return NullClient.new(type) unless config

          SERVICE_MAP[type].new(
            config.url,
            config.credentials,
            interceptors: config.interceptors
          )
        end
      end
    end
  end
end
