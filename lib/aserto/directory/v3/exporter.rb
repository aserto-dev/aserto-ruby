# frozen_string_literal: true

module Aserto
  module Directory
    module V3
      module Exporter
        DATA_TYPE = {
          unknown: 0x0,
          objects: 0x8,
          relations: 0x10,
          all: 0x18
        }.freeze

        def export(data_type: :unknown)
          data = []
          operation = exporter.export(
            Aserto::Directory::Exporter::V3::ExportRequest.new(options: DATA_TYPE[data_type]),
            return_op: true
          )

          response = operation.execute
          response.each { |r| data.push(r) }
          operation.wait

          data
        end
      end
    end
  end
end
