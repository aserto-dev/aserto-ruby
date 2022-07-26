# frozen_string_literal: true

describe Aserto::Authorization do
  def env_for(url, opts = {})
    Rack::MockRequest.env_for(url, opts)
  end

  let(:app) { ->(env) { [200, env, "app"] } }
  let(:options) { {} }
  let(:auth_client_spy) { instance_spy(Aserto::AuthClient) }
  let(:middleware) { described_class.new(app, options) }

  context "when not enabled" do
    before do
      allow(Aserto::AuthClient).to receive(:new).and_return(auth_client_spy)
      Aserto.config.enabled = false
    end

    after do
      Aserto.config.enabled = true
    end

    it "does not authorize" do
      middleware.call env_for("http://test.com")

      expect(auth_client_spy).not_to have_received(:is)
    end
  end

  context "when enabled" do
    before do
      Aserto.config.enabled = true
      Aserto.config.decision = "allowed"
    end

    context "when allowed" do
      before do
        GrpcMock.stub_request("/aserto.authorizer.authorizer.v1.Authorizer/Is").to_return do
          Aserto::Authorizer::Authorizer::V1::IsResponse.new(
            { decisions: [
              { decision: "allowed", is: true },
              { decision: "visible", is: false },
              { decision: "enabled", is: false }
            ] }
          )
        end
      end

      it "forwards the request" do
        response = middleware.call env_for("http://test.com")

        expect(response[0]).to eq(200)
      end
    end

    context "when not allowed" do
      before do
        GrpcMock.stub_request("/aserto.authorizer.authorizer.v1.Authorizer/Is").to_return do
          Aserto::Authorizer::Authorizer::V1::IsResponse.new(
            { decisions: [
              { decision: "allowed", is: false },
              { decision: "visible", is: false },
              { decision: "enabled", is: false }
            ] }
          )
        end
      end

      it "returns forbidden" do
        response = middleware.call env_for("http://test.com")

        expect(response[0]).to eq(403)
      end
    end
  end
end
