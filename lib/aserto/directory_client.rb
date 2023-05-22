# frozen_string_literal: true

require "aserto/directory"
require_relative "metadata_interceptor"

module Aserto
  class DirectoryClient
    def initialize(url: "directory.eng.aserto.com:8443", api_key: nil, tenant_id: nil, cert_path: nil)
      channel_credentials = if cert_path && File.file?(cert_path)
                              GRPC::Core::ChannelCredentials.new(File.read(cert_path))
                            else
                              GRPC::Core::ChannelCredentials.new

                            end
      args = if api_key && tenant_id
               { interceptors: [MetadataInterceptor.new(
                 api_key: api_key, tenant_id: tenant_id
               )] }
             else
               {}
             end
      @reader_client = ::Aserto::Directory::Reader::V2::Reader::Stub.new(url, channel_credentials, args)
    end

    def object(type:, key:)
      object_identifier = Aserto::Directory::Common::V2::ObjectIdentifier.new(type: type, key: key)
      request = ::Aserto::Directory::Reader::V2::GetObjectRequest.new(param: object_identifier)
      @reader_client.get_object(request)
    end

    def relation(subject:, object:, relation:)
      subject_identifier = ::Aserto::Directory::Common::V2::ObjectIdentifier.new(subject)
      object_identifier = ::Aserto::Directory::Common::V2::ObjectIdentifier.new(object)
      relation_type_identifier = ::Aserto::Directory::Common::V2::RelationTypeIdentifier.new(relation)
      relation_identifier = ::Aserto::Directory::Common::V2::RelationIdentifier.new(subject: subject_identifier,
                                                                                    object: object_identifier,
                                                                                    relation: relation_type_identifier)
      request = Aserto::Directory::Reader::V2::GetRelationRequest.new(param: relation_identifier)
      @reader_client.get_relation(request)
    end
  end
end
