# frozen_string_literal: true

module Aserto
  module Directory
    module V3
      module Exporter
        DATA_TYPE = {
          unknown: ::Aserto::Directory::Exporter::V3::Option::OPTION_UNKNOWN,
          objects: ::Aserto::Directory::Exporter::V3::Option::OPTION_DATA_OBJECTS,
          relations: ::Aserto::Directory::Exporter::V3::Option::OPTION_DATA_RELATIONS,
          all: ::Aserto::Directory::Exporter::V3::Option::OPTION_DATA
        }.freeze

        #
        # Exports directory data
        #
        # @param [String] data_type one of [:unknown, :objects, :relations, :all]
        #
        def export(data_type: :unknown)
          operation = exporter.export(
            Aserto::Directory::Exporter::V3::ExportRequest.new(options: DATA_TYPE[data_type]),
            return_op: true
          )

          response = operation.execute
          data = response.map { |r| r }
          operation.wait

          data
        end
      end
    end
  end
end
