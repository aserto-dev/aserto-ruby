# frozen_string_literal: true

require "aserto/directory"
require_relative "../interceptors/headers"
require_relative "requests"

module Aserto
  module Directory
    module V2
      class Client
        include Requests

        # Creates a new Directory V2 Client
        #
        # @param url [String] the gRpc url of the directory server
        # @param api_key [String] the api key of the directory server(for hosted directory)
        # @param tenant_id [String] the tenant id of the directory server(for hosted directory)
        # @param cert_path [String] the path to the certificates folder
        #
        # @return [Aserto::Directory::V2::Client] the new Directory Client
        def initialize(url: "directory.prod.aserto.com:8443", api_key: nil, tenant_id: nil, cert_path: nil)
          @reader_client = ::Aserto::Directory::Reader::V2::Reader::Stub.new(
            url,
            load_creds(cert_path),
            interceptors: [Interceptors::Headers.new(api_key, tenant_id)]
          )
          @writer_client = ::Aserto::Directory::Writer::V2::Writer::Stub.new(
            url,
            load_creds(cert_path),
            interceptors: [Interceptors::Headers.new(api_key, tenant_id)]
          )
        end

        # Check permissions
        #
        # @param subject [::Aserto::Directory::Common::V2::ObjectIdentifier]
        # @param permission [String] permission name to be checked
        # @param object [::Aserto::Directory::Common::V2::ObjectIdentifier]
        # @param trace [Boolean] whether to enable tracing
        #
        # @return [Boolean]
        def check_permission(subject:, permission:, object:, trace: false)
          reader_client.check_permission(check_permission_request(subject, permission, object, trace))
        end

        # Check relation
        #
        # @param subject [::Aserto::Directory::Common::V2::ObjectIdentifier]
        # @param relation [::Aserto::Directory::Common::V2::RelationTypeIdentifier] relation name to be checked
        # @param object [::Aserto::Directory::Common::V2::ObjectIdentifier]
        # @param trace [Boolean] whether to enable tracing
        #
        # @return [Boolean]
        def check_relation(subject:, relation:, object:, trace: false)
          reader_client.check_relation(check_relation_request(subject, relation, object, trace))
        end

        # Get an object by type and key
        #
        # @param type [String] the type of object
        # @param key [String] the key of the object
        #
        # @return [::Aserto::Directory::Common::V2::Object]
        def object(type:, key:)
          reader_client.get_object(object_request(key, type)).result
        end

        # Set an object
        #
        # @param object [::Aserto::Directory::Common::V2::Object]
        #
        # @return [::Aserto::Directory::Common::V2::Object] the created/updated object
        def set_object(object:)
          writer_client.set_object(new_object_request(object)).result
        end

        # Get a list of objects by type
        #
        # @param type [String] the type of objects
        # @param page [::Aserto::Directory::Common::V2::PaginationRequest]
        #
        # @return [Array<::Aserto::Directory::Common::V2::Object>]
        def objects(type:, page: nil)
          reader_client.get_objects(objects_request(type, page)).results
        end

        # Get a relation
        #
        # @param subject [::Aserto::Directory::Common::V2::ObjectIdentifier]
        # @param relation [::Aserto::Directory::Common::V2::RelationTypeIdentifier]
        # @param object [::Aserto::Directory::Common::V2::ObjectIdentifier]
        #
        # @return [::Aserto::Directory::Common::V2::Relation]
        def relation(subject: nil, relation: nil, object: nil)
          reader_client.get_relation(relation_request(subject, relation, object)).results
        end

        # Get a list of relations
        #
        # @param subject [::Aserto::Directory::Common::V2::ObjectIdentifier]
        # @param relation [::Aserto::Directory::Common::V2::RelationTypeIdentifier]
        # @param object [::Aserto::Directory::Common::V2::ObjectIdentifier]
        #
        # @return [Array<::Aserto::Directory::Common::V2::Relation>]
        def relations(subject: nil, relation: nil, object: nil, page: nil)
          reader_client.get_relations(relations_request(subject, relation, object, page)).results
        end

        # Set a relation
        # @param subject [::Aserto::Directory::Common::V2::ObjectIdentifier]
        # @param relation [String] name of the relation
        # @param object [::Aserto::Directory::Common::V2::ObjectIdentifier]
        # @param hash [String] hash of the relation(required for updating a relation)
        #
        # @return [::Aserto::Directory::Common::V2::Relation] the created/updated relation
        def set_relation(subject:, relation:, object:, hash: nil)
          writer_client.set_relation(new_relation_request(subject, relation, object, hash)).result
        end

        # Delete a relation
        #
        # @param subject [::Aserto::Directory::Common::V2::ObjectIdentifier]
        # @param relation [::Aserto::Directory::Common::V2::RelationTypeIdentifier]
        # @param object [::Aserto::Directory::Common::V2::ObjectIdentifier]
        #
        # @return nil
        def delete_relation(subject:, relation:, object:)
          writer_client.delete_relation(delete_relation_request(subject, relation, object))
        end

        private

        attr_reader :reader_client, :writer_client

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
