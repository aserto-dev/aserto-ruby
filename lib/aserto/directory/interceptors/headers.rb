# frozen_string_literal: true

module Aserto
  module Directory
    module Interceptors
      class Headers < GRPC::ClientInterceptor
        def initialize(api_key, tenant_id)
          @api_key = api_key
          @tenant_id = tenant_id
          super()
        end

        def request_response(method:, request:, call:, metadata:)
          metadata["aserto-tenant-id"] = @tenant_id
          metadata["authorization"] = @api_key

          yield(method, request, call, metadata)
        end
      end
    end
  end
end
