# frozen_string_literal: true

describe Aserto::Directory::V3::Client do
  let(:client) { described_class.new(tenant_id: "1234", api_key: "basic test") }

  describe ".reader" do
    describe ".get_object" do
      before do
        GrpcMock.stub_request("/aserto.directory.reader.v3.Reader/GetObject").to_return do
          Aserto::Directory::Reader::V3::GetObjectResponse.new(
            { result: { id: "id", type: "type", display_name: "display_name" } }
          )
        end
      end

      it "returns the correct object" do
        expect(client.reader.get_object(
          Aserto::Directory::Reader::V3::GetObjectRequest.new(
            object_id: "id",
            object_type: "type"
          )
        ).to_h).to eq(
          {
            result: {
              created_at: nil,
              display_name: "display_name",
              etag: "",
              id: "id",
              properties: nil,
              type: "type",
              updated_at: nil
            },
            relations: [],
            page: nil
          }
        )
      end
    end
  end
end
