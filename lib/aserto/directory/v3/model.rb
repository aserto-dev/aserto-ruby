# frozen_string_literal: true

module Aserto
  module Directory
    module V3
      module Model
        # rubocop:disable Naming/AccessorMethodName

        # Get the content of a manifest
        # @return [Hash] { body: String, updated_at: Timestap, etag: String }
        def get_manifest
          response = {}
          manifest_enum = @model.get_manifest(Aserto::Directory::Model::V3::GetManifestRequest.new)
          manifest_enum.each do |resp|
            response[:body] = resp.body.data if resp.respond_to?(:body) && !resp.body.nil?
            if resp.respond_to?(:metadata)
              response[:updated_at] ||= resp.metadata&.updated_at&.to_time
              response[:etag] ||= resp.metadata&.etag
            end
          end

          response
        end

        # Set the content of a manifest
        # @param body [String]
        # @return [Aserto::Directory::Model::V3::SetManifestResponse]
        def set_manifest(body)
          @model.set_manifest([Aserto::Directory::Model::V3::SetManifestRequest.new(body: { data: body })])
        end

        # rubocop:enable Naming/AccessorMethodName
      end
    end
  end
end
