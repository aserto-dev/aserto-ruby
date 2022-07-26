# frozen_string_literal: true

describe Aserto::AuthClient do
  let(:request) do
    Rack::Request.new(
      Rack::MockRequest.env_for(
        "http://localhost:8080/",
        "REQUEST_METHOD" => "GET",
        "PATH_INFO" => "/"
      )
    )
  end

  let(:client) { described_class.new(request) }

  describe ".is" do
    subject { client.is }

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

      it { is_expected.to be_truthy }
    end

    context "when not allowed" do
      before do
        GrpcMock.stub_request("/aserto.authorizer.authorizer.v1.Authorizer/Is").to_return do
          Aserto::Authorizer::Authorizer::V1::IsResponse.new(
            { decisions: [
              { decision: "allowed", is: false },
              { decision: "visible", is: true },
              { decision: "enabled", is: true }
            ] }
          )
        end
      end

      it { is_expected.to be_falsey }
    end

    context "when error" do
      before do
        GrpcMock.stub_request("/aserto.authorizer.authorizer.v1.Authorizer/Is").to_raise(GRPC::BadStatus)
      end

      it { is_expected.to be_falsey }
    end

    context "when chaning default decision" do
      let(:initial_decision) { Aserto.config.decision }

      before do
        Aserto.configure do |config|
          config.decision = "visible"
        end
      end

      after do
        Aserto.configure do |config|
          config.decision = initial_decision
        end
      end

      context "when visible" do
        before do
          GrpcMock.stub_request("/aserto.authorizer.authorizer.v1.Authorizer/Is").to_return do
            Aserto::Authorizer::Authorizer::V1::IsResponse.new(
              { decisions: [
                { decision: "allowed", is: false },
                { decision: "visible", is: true },
                { decision: "enabled", is: false }
              ] }
            )
          end
        end

        it { is_expected.to be_truthy }
      end

      context "when not visible" do
        before do
          GrpcMock.stub_request("/aserto.authorizer.authorizer.v1.Authorizer/Is").to_return do
            Aserto::Authorizer::Authorizer::V1::IsResponse.new(
              { decisions: [
                { decision: "allowed", is: true },
                { decision: "visible", is: false },
                { decision: "enabled", is: true }
              ] }
            )
          end
        end

        it { is_expected.to be_falsey }
      end
    end
  end

  describe ".allowed?" do
    subject { client }

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

      it { is_expected.to be_allowed }
    end

    context "when not allowed" do
      before do
        GrpcMock.stub_request("/aserto.authorizer.authorizer.v1.Authorizer/Is").to_return do
          Aserto::Authorizer::Authorizer::V1::IsResponse.new(
            { decisions: [
              { decision: "allowed", is: false },
              { decision: "visible", is: true },
              { decision: "enabled", is: true }
            ] }
          )
        end
      end

      it { is_expected.not_to be_allowed }
    end
  end

  describe ".visible?" do
    subject { client }

    context "when visible" do
      before do
        GrpcMock.stub_request("/aserto.authorizer.authorizer.v1.Authorizer/Is").to_return do
          Aserto::Authorizer::Authorizer::V1::IsResponse.new(
            { decisions: [
              { decision: "allowed", is: false },
              { decision: "visible", is: true },
              { decision: "enabled", is: false }
            ] }
          )
        end
      end

      it { is_expected.to be_visible }
    end

    context "when not visible" do
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

      it { is_expected.not_to be_visible }
    end
  end

  describe ".enabled?" do
    subject { client }

    context "when enabled" do
      before do
        GrpcMock.stub_request("/aserto.authorizer.authorizer.v1.Authorizer/Is").to_return do
          Aserto::Authorizer::Authorizer::V1::IsResponse.new(
            { decisions: [
              { decision: "allowed", is: false },
              { decision: "visible", is: false },
              { decision: "enabled", is: true }
            ] }
          )
        end
      end

      it { is_expected.to be_enabled }
    end

    context "when not enabled" do
      before do
        GrpcMock.stub_request("/aserto.authorizer.authorizer.v1.Authorizer/Is").to_return do
          Aserto::Authorizer::Authorizer::V1::IsResponse.new(
            { decisions: [
              { decision: "allowed", is: true },
              { decision: "visible", is: true },
              { decision: "enabled", is: false }
            ] }
          )
        end
      end

      it { is_expected.not_to be_enabled }
    end
  end
end
