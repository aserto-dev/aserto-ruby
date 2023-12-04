# frozen_string_literal: true

describe Aserto::Directory::V3::Client do
  describe("client") do
    describe("reader") do
      it "inherits base config" do
        client = described_class.new({ tenant_id: "1234", api_key: "basic test" })
        expect(
          client.instance_variable_get(:@reader).instance_variable_get(:@host)
        ).to eql("directory.prod.aserto.com:8443")
      end

      it "allows overwriting base config" do
        client = described_class.new({ url: "base.com", tenant_id: "1234", api_key: "basic test" })
        expect(
          client.instance_variable_get(:@reader).instance_variable_get(:@host)
        ).to eql("base.com")
      end

      it "allows specific reader config" do
        client = described_class.new(
          { url: "base.com", tenant_id: "1234", api_key: "basic test",
            reader: { url: "reader.com" } }
        )
        expect(
          client.instance_variable_get(:@reader).instance_variable_get(:@host)
        ).to eql("reader.com")
      end

      it "provides an informative error message if the client is missing" do
        client = described_class.new({})

        expect do
          client.get_object(object_id: "1234", object_type: "object")
        end.to output("Cannot call 'get_object': 'Reader' client is not initialized.\n").to_stdout
      end
    end

    context("when using partial config") do
      let(:client) { described_class.new({ reader: { tenant_id: "1234", api_key: "basic test" } }) }

      it "provides an informative error message for writer" do
        expect do
          client.set_object(object_id: "1234", object_type: "object")
        end.to output("Cannot call 'set_object': 'Writer' client is not initialized.\n").to_stdout
      end

      it "creates the requested service object" do
        expect(client.instance_variable_get(:@reader)).to be_a(Aserto::Directory::Reader::V3::Reader::Stub)
      end

      it "configures the correct host" do
        expect(
          client.instance_variable_get(:@reader).instance_variable_get(:@host)
        ).to eql("directory.prod.aserto.com:8443")
      end
    end
  end

  describe ".reader" do
    let(:client) { described_class.new(tenant_id: "1234", api_key: "basic test") }

    describe ".get_object" do
      before do
        GrpcMock.stub_request("/aserto.directory.reader.v3.Reader/GetObject").to_return do
          Aserto::Directory::Reader::V3::GetObjectResponse.new(
            { result: { id: "id", type: "type", display_name: "display_name" } }
          )
        end
      end

      it "returns the correct object" do
        expect(client.get_object(
          object_id: "id",
          object_type: "type"
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
