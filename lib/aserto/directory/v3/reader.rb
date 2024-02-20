# frozen_string_literal: true

module Aserto
  module Directory
    module V3
      module Reader
        #
        # find an object by id and type
        #
        # @param object_type [String]
        # @param object_id [String]
        #
        # @return [Aserto::Directory::Reader::V3::GetObjectResponse]
        #
        # @example
        #   client.get_object(
        #     object_type: "user",
        #     object_id: "rick@the-citadel.com"
        #   )
        def get_object(object_type:, object_id:)
          reader.get_object(
            Aserto::Directory::Reader::V3::GetObjectRequest.new(
              object_type: object_type,
              object_id: object_id
            )
          )
        end

        #
        # list objects by type
        #
        # @param object_type [String]
        # @param page [Hash]
        # @option page [Integer] :size
        # @option page [String] :token
        #
        # @return [Aserto::Directory::V3::GetObjectsResponse]
        #
        # @example
        #   client.get_objects(
        #      object_type: "user",
        #      page: { size: 2 }
        #   )
        def get_objects(object_type:, page: { size: 100 })
          reader.get_objects(
            Aserto::Directory::Reader::V3::GetObjectsRequest.new(
              object_type: object_type,
              page: Aserto::Directory::Common::V3::PaginationRequest.new(page)
            )
          )
        end

        #
        # find a relation between two objects
        #
        # @param [String] object_type
        # @param [String] object_id
        # @param [String] relation
        # @param [String] subject_type
        # @param [String] subject_id
        # @param [String] subject_relation
        # @param [Boolean] with_objects
        #
        # @return [Aserto::Directory::Reader::V3::GetRelationResponse]
        #
        # @example
        #   client.get_relation(
        #     object_type: "user",
        #     object_id: "rick@the-citadel.com",
        #     relation: "member",
        #     object_type: "group",
        #     object_id: "evil_genius"
        #   )
        def get_relation(object_type:, object_id:, relation:, subject_type:, subject_id:, subject_relation: "",
                         with_objects: false)
          reader.get_relation(
            Aserto::Directory::Reader::V3::GetRelationRequest.new(
              object_type: object_type,
              object_id: object_id,
              relation: relation,
              subject_type: subject_type,
              subject_id: subject_id,
              subject_relation: subject_relation,
              with_objects: with_objects
            )
          )
        end

        #
        # List relations between two objects
        #
        # @param [String] object_type
        # @param [String] object_id
        # @param [String] relation
        # @param [String] subject_type
        # @param [String] subject_id
        # @param [String] subject_relation
        # @param [Boolean] with_objects
        # @param page [Hash]
        # @option page [Integer] :size
        # @option page [String] :token
        #
        # @return [Aserto::Directory::Reader::V3::GetRelationsResponse]
        #
        # @example
        #   client.get_relations(
        #     object_type: "user",
        #     object_id: "rick@the-citadel.com",
        #     relation: "member",
        #     page: { size: 10 }
        #   )
        def get_relations(object_type: "", object_id: "", relation: "", subject_type: "", subject_id: "",
                          subject_relation: "", with_objects: false, page: { size: 100 })
          reader.get_relations(
            Aserto::Directory::Reader::V3::GetRelationsRequest.new(
              object_type: object_type,
              object_id: object_id,
              relation: relation,
              subject_type: subject_type,
              subject_id: subject_id,
              subject_relation: subject_relation,
              with_objects: with_objects,
              page: Aserto::Directory::Common::V3::PaginationRequest.new(page)
            )
          )
        end

        #
        # Check relation between two objects
        #
        # @param [String] object_type
        # @param [String] object_id
        # @param [String] relation
        # @param [String] subject_type
        # @param [String] subject_id
        # @param [Boolean] trace
        #
        # @return [Aserto::Directory::Reader::V3::CheckRelationResponse]
        #
        # @example
        #   client.check_relation(
        #     object_type: "user",
        #     object_id: "rick@the-citadel.com",
        #     relation: "member",
        #     object_type: "group",
        #     object_id: "evil_genius"
        #   )
        def check_relation(object_type:, object_id:, relation:, subject_type:, subject_id:, trace: false)
          reader.check_relation(
            Aserto::Directory::Reader::V3::CheckRelationRequest.new(
              object_type: object_type,
              object_id: object_id,
              relation: relation,
              subject_type: subject_type,
              subject_id: subject_id,
              trace: trace
            )
          )
        end

        #
        # Check relation between two objects
        #
        # @param [String] object_type
        # @param [String] object_id
        # @param [String] relation
        # @param [String] subject_type
        # @param [String] subject_id
        # @param [Boolean] trace
        #
        # @return [Aserto::Directory::Reader::V3::CheckResponse]
        #
        # @example
        #   client.check(
        #     object_type: "user",
        #     object_id: "rick@the-citadel.com",
        #     relation: "member",
        #     object_type: "group",
        #     object_id: "evil_genius"
        #   )
        def check(object_type:, object_id:, relation:, subject_type:, subject_id:, trace: false)
          reader.check(
            Aserto::Directory::Reader::V3::CheckRequest.new(
              object_type: object_type,
              object_id: object_id,
              relation: relation,
              subject_type: subject_type,
              subject_id: subject_id,
              trace: trace
            )
          )
        end

        #
        # Check permission between two objects
        #
        # @param [String] object_type
        # @param [String] object_id
        # @param [String] permission
        # @param [String] subject_type
        # @param [String] subject_id
        # @param [Boolean] trace
        #
        # @return [Aserto::Directory::Reader::V3::CheckPermissionResponse]
        #
        # @example
        #   client.check_permission(
        #     object_type: "user",
        #     object_id: "rick@the-citadel.com",
        #     permission: "read",
        #     object_type: "group",
        #     object_id: "evil_genius"
        #   )
        def check_permission(object_type:, object_id:, permission:, subject_type:, subject_id:, trace: false)
          reader.check_permission(
            Aserto::Directory::Reader::V3::CheckPermissionRequest.new(
              object_type: object_type,
              object_id: object_id,
              permission: permission,
              subject_type: subject_type,
              subject_id: subject_id,
              trace: trace
            )
          )
        end

        #
        # Returns object graph from anchor to subject or object.
        #
        # @param [String] object_type
        # @param [String] object_id
        # @param [String] relation
        # @param [String] subject_type
        # @param [String]
        #
        # @return [Aserto::Directory::Reader::V3::GetGraphResponse]
        #
        # @example
        #   directory.get_graph(
        #     object_type: "user",
        #     object_id: "rick@the-citadel.com",
        #     subject_id: "rick@the-citadel.com",
        #     subject_type: "user",
        #     relation: "member"
        #   )
        def get_graph(object_type:, relation:, subject_type:, object_id: "",
                      subject_id: "", subject_relation: "", explain: false, trace: false)
          reader.get_graph(
            Aserto::Directory::Reader::V3::GetGraphRequest.new(
              object_type: object_type,
              object_id: object_id,
              relation: relation,
              subject_type: subject_type,
              subject_id: subject_id,
              subject_relation: subject_relation,
              explain: explain,
              trace: trace
            )
          )
        end
      end
    end
  end
end
