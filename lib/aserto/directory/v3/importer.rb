# frozen_string_literal: true

module Aserto
  module Directory
    module V3
      module Importer
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
