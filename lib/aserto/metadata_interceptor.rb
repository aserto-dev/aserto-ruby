# frozen_string_literal: true

class MetadataInterceptor < GRPC::ClientInterceptor
  def initialize(api_key: nil, tenant_id: nil)
    @api_key = api_key
    @tenant_id = tenant_id
  end

  def request_response(method:, request:, call:, metadata:)
    metadata["aserto-tenant-id"] = @tenant_id
    metadata["authorization"] = @api_key
    yield
  end
end
