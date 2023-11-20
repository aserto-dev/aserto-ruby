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
        #       { object: { id: "import-user", type: "user" } },
        #       { object: { id: "import-group", type: "group" } },
        #       {
        #         relation: {
        #           object_id: "import-user",
        #           object_type: "user",
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
