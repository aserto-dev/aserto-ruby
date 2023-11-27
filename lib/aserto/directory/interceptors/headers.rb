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

        def request_response(request: nil, call: nil, method: nil, metadata: nil)
          update_metadata(metadata)
          yield(request, call, method, metadata)
        end

        def bidi_streamer(requests: nil, call: nil, method: nil, metadata: nil)
          update_metadata(metadata)
          yield(requests, call, method, metadata)
        end

        def client_streamer(requests: nil, call: nil, method: nil, metadata: nil)
          update_metadata(metadata)
          yield(requests, call, method, metadata)
        end

        def server_streamer(request: nil, call: nil, method: nil, metadata: nil)
          update_metadata(metadata)
          yield(request, call, method, metadata)
        end

        private

        def update_metadata(metadata)
          metadata["aserto-tenant-id"] = @tenant_id
          metadata["authorization"] = @api_key
        end
      end
    end
  end
end
