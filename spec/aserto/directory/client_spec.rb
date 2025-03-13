# frozen_string_literal: true

describe Aserto::Directory::Client do
  let(:client) { described_class.new(tenant_id: "1234", api_key: "basic test") }

  describe ".object" do
    before do
      GrpcMock.stub_request("/aserto.directory.reader.v2.Reader/GetObject").to_return do
        Aserto::Directory::Reader::V2::GetObjectResponse.new(
          { result: Aserto::Directory::Common::V2::Object.new(
            key: "key", type: "type", display_name: "display_name"
          ) }
        )
      end
    end

    it "returns the correct object" do
      expect(client.object(type: "type", key: "key").to_h).to eq(
        {
          display_name: "display_name",
          key: "key",
          type: "type"
        }
      )
    end
  end
end
