# frozen_string_literal: true

module Aserto
  module Directory
    module V3
      module Writer
        require "google/protobuf/well_known_types"

        #
        # Create a new object
        #
        # @param [String] object_type
        # @param [String] object_id
        # @param [String] display_name
        # @param [Hash] properties
        # @param [String] etag
        #
        # @return [Aserto::Directory::Writer::V3::SetObjectResponse]
        #
        # @example
        #   client.set_object(object_type: "user", object_id: "1234", properties: { email: "test" })
        def set_object(object_type:, object_id:, display_name: "", properties: {}, etag: nil)
          writer.set_object(
            Aserto::Directory::Writer::V3::SetObjectRequest.new(
              object: {
                type: object_type,
                id: object_id,
                display_name: display_name,
                properties: Google::Protobuf::Struct.from_hash(properties.transform_keys!(&:to_s)),
                etag: etag
              }
            )
          )
        end

        #
        # Delete an object
        #
        # @param [String] object_type
        # @param [String] object_id
        # @param [Boolean] with_relations
        #
        # @return [ Aserto::Directory::Writer::V3::DeleteObjectResponse]
        #
        # @example
        #   client.delete_object(object_type: "user", object_id: "1234")
        def delete_object(object_type:, object_id:, with_relations: false)
          writer.delete_object(
            Aserto::Directory::Writer::V3::DeleteObjectRequest.new(
              object_type: object_type,
              object_id: object_id,
              with_relations: with_relations
            )
          )
        end

        #
        # Creates a relation between two objects
        #
        # @param [String] object_type
        # @param [String] object_id
        # @param [String] relation
        # @param [String] subject_type
        # @param [String] subject_id
        #
        # @return [Aserto::Directory::Writer::V3::SetRelationResponse]
        #
        # @example
        #   client.set_relation(
        #     object_type: "user",
        #     object_id: "rick@the-citadel.com",
        #     relation: "member",
        #     object_type: "group",
        #     object_id: "evil_genius"
        #   )
        def set_relation(object_type:, object_id:, relation:, subject_type:, subject_id:)
          writer.set_relation(
            Aserto::Directory::Writer::V3::SetRelationRequest.new(
              relation: {
                object_type: object_type,
                object_id: object_id,
                relation: relation,
                subject_type: subject_type,
                subject_id: subject_id
              }
            )
          )
        end

        #
        # Delete a relation between two objects
        #
        # @param [String] object_type
        # @param [String] object_id
        # @param [String] relation
        # @param [String] subject_type
        # @param [String] subject_id
        # @param [String] subject_relation
        #
        # @return [Aserto::Directory::Writer::V3::DeleteRelationRequest]
        #
        # @example
        #   client.get_relation(
        #     object_type: "user",
        #     object_id: "rick@the-citadel.com",
        #     relation: "member",
        #     object_type: "group",
        #     object_id: "evil_genius"
        #   )
        def delete_relation(object_type:, object_id:, relation:, subject_type:, subject_id:, subject_relation: "")
          writer.delete_relation(
            Aserto::Directory::Writer::V3::DeleteRelationRequest.new(
              object_type: object_type,
              object_id: object_id,
              relation: relation,
              subject_type: subject_type,
              subject_id: subject_id,
              subject_relation: subject_relation
            )
          )
        end
      end
    end
  end
end
