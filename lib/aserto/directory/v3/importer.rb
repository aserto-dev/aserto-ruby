# frozen_string_literal: true

module Aserto
  module Directory
    module V3
      module Importer
        #
        # Imports objects and relations
        #
        # @param Array[Hash] data to be imported
        #
        # @example
        #   directory.import(
        #     [
        #       { object: { type: "user", id: "import-user" } },
        #       { object: { type: "group", id: "import-group" } },
        #       {
        #         relation: {
        #           object_type: "user",
        #           object_id: "import-user",
        #           relation: "member",
        #           subject_id: "import-group",
        #           subject_type: "group"
        #         }
        #       }
        #     ]
        #   )
        def import(data)
          data.map! do |value|
            Aserto::Directory::Importer::V3::ImportRequest.new(value)
          end
          operation = importer.import(data, return_op: true)
          response = operation.execute
          response.each { |r| } # ensures that the server sends trailing data
          operation.wait
        end
      end
    end
  end
end
