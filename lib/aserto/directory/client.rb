# frozen_string_literal: true

require_relative "v2/client"

module Aserto
  module Directory
    class Client
      # Creates a new Directory Client
      #
      # @param url [String] the gRpc url of the directory server
      # @param api_key [String] the api key of the directory server(for hosted directory)
      # @param tenant_id [String] the tenant id of the directory server(for hosted directory)
      # @param cert_path [String] the path to the certificates folder
      #
      # @return [Aserto::Directory::Client] the new Directory Client

      def initialize(url: "directory.prod.aserto.com:8443", api_key: nil, tenant_id: nil, cert_path: nil)
        warn WARN_MESSAGE

        @v2_client = Aserto::Directory::V2::Client.new(
          url: url, api_key: api_key, tenant_id: tenant_id, cert_path: cert_path
        )
      end

      def method_missing(method, args)
        @v2_client.send(method, **args)
      end

      def respond_to_missing?(_name, _include_private)
        true
      end

      WARN_MESSAGE = <<~TEXT
        Aserto::Directory::Client is deprecated and will be removed.
        Use Aserto::Directory::V3::Client for the latest Directory Client.
        If you still want to need Directory V2, use Aserto::Directory::V3::Client
      TEXT
    end
  end
end
