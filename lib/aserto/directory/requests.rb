# frozen_string_literal: true

module Aserto
  module Directory
    module Requests
      private

      def check_permission_request(subject, permission, object, trace)
        subject_identifier = ::Aserto::Directory::Common::V2::ObjectIdentifier.new(subject)
        permission_identifier = ::Aserto::Directory::Common::V2::PermissionIdentifier.new(permission)
        object_identifier = ::Aserto::Directory::Common::V2::ObjectIdentifier.new(object)
        ::Aserto::Directory::Reader::V2::CheckPermissionRequest.new(
          {
            object: object_identifier,
            subject: subject_identifier,
            permission: permission_identifier,
            trace: trace
          }
        )
      end

      def check_relation_request(subject, relation, object, trace)
        subject_identifier = ::Aserto::Directory::Common::V2::ObjectIdentifier.new(subject)
        relation_identifier = ::Aserto::Directory::Common::V2::RelationTypeIdentifier.new(relation)
        object_identifier = ::Aserto::Directory::Common::V2::ObjectIdentifier.new(object)
        ::Aserto::Directory::Reader::V2::CheckRelationRequest.new(
          {
            object: object_identifier,
            subject: subject_identifier,
            relation: relation_identifier,
            trace: trace
          }
        )
      end

      def object_request(key, type)
        object_identifier = ::Aserto::Directory::Common::V2::ObjectIdentifier.new(type: type, key: key)
        ::Aserto::Directory::Reader::V2::GetObjectRequest.new(param: object_identifier)
      end

      def new_object_request(object)
        ::Aserto::Directory::Writer::V2::SetObjectRequest.new(object: object)
      end

      def objects_request(type, page)
        object_type_identifier = ::Aserto::Directory::Common::V2::ObjectTypeIdentifier.new(
          { name: type }
        )
        ::Aserto::Directory::Reader::V2::GetObjectsRequest.new(param: object_type_identifier, page: page)
      end

      def relation_request(subject, relation, object)
        ::Aserto::Directory::Reader::V2::GetRelationRequest.new(
          param: relation_identifier(subject, relation, object)
        )
      end

      def relations_request(subject, relation, object, page)
        ::Aserto::Directory::Reader::V2::GetRelationsRequest.new(
          param: relation_identifier(subject, relation, object),
          page: page
        )
      end

      def new_relation_request(subject, relation, object, hash)
        subject_identifier = ::Aserto::Directory::Common::V2::ObjectIdentifier.new(subject)
        object_identifier = ::Aserto::Directory::Common::V2::ObjectIdentifier.new(object)
        ::Aserto::Directory::Writer::V2::SetRelationRequest.new(
          {
            relation: {
              subject: subject_identifier,
              relation: relation,
              object: object_identifier,
              hash: hash
            }
          }
        )
      end

      def delete_relation_request(subject, relation, object)
        ::Aserto::Directory::Writer::V2::DeleteRelationRequest.new(
          param: relation_identifier(subject, relation, object)
        )
      end

      def relation_identifier(subject, relation, object)
        relation_identifier = ::Aserto::Directory::Common::V2::RelationIdentifier.new
        relation_identifier.subject = ::Aserto::Directory::Common::V2::ObjectIdentifier.new(subject) if subject
        relation_identifier.relation = ::Aserto::Directory::Common::V2::RelationTypeIdentifier.new(relation) if relation
        relation_identifier.object = ::Aserto::Directory::Common::V2::ObjectIdentifier.new(object) if object
        relation_identifier
      end
    end
  end
end
