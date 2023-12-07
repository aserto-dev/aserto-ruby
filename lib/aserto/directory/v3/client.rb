# frozen_string_literal: true

require "aserto/directory"
require_relative "../interceptors/headers"
require_relative "config"
require_relative "reader"
require_relative "writer"
require_relative "model"
require_relative "importer"
require_relative "exporter"
require_relative "../errors"

module Aserto
  module Directory
    module V3
      class Client
        extend Forwardable
        include ::Aserto::Directory::V3::Reader
        # @!parse include ::Aserto::Directory::V3::Reader

        include ::Aserto::Directory::V3::Writer
        # @!parse include ::Aserto::Directory::V3::Writer

        include ::Aserto::Directory::V3::Model
        # @!parse include ::Aserto::Directory::V3::Model

        include ::Aserto::Directory::V3::Importer
        # @!parse include ::Aserto::Directory::V3::Importer

        include ::Aserto::Directory::V3::Exporter
        # @!parse include ::Aserto::Directory::V3::Exporter

        # Creates a new Directory V3 Client
        #
        # @param config [Aserto::Directory::V3::Config] the service configuration
        # Base configuration
        # If non-nil, this configuration is used for any client that doesn't have its own configuration.
        # If nil, only clients that have their own configuration will be created.
        #
        # @example Create a new Directory V3 Client with all the services
        #   client = Aserto::Directory::V3::Client.new(
        #     {
        #       url: "directory.eng.aserto.com:8443",
        #       tenant_id: "tenant-id",
        #       api_key: "basic api-key",
        #     }
        #   )
        #
        # @example Create a new Directory V3 Client with reader only
        #   client = Aserto::Directory::V3::Client.new(
        #     {
        #       reader: {
        #         url: "directory.eng.aserto.com:8443",
        #         tenant_id: "tenant-id",
        #         api_key: "basic api-key",
        #       }
        #     }
        #   )
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

        attr_reader :reader, :writer, :model, :importer, :exporter

        class NullClient
          def initialize(name)
            @name = name
          end

          def method_missing(method, *_args)
            raise ConfigError, "Cannot call '#{method}': '#{@name.to_s.capitalize}' client is not initialized."
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

      remove_const(:Reader)
      remove_const(:Writer)
      remove_const(:Model)
      remove_const(:Importer)
      remove_const(:Exporter)
    end
  end
end
