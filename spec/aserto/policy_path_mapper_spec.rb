# frozen_string_literal: true

describe Aserto::PolicyPathMapper do
  describe ".execute" do
    data = [
      {
        REQUEST: Rack::Request.new(
          Rack::MockRequest.env_for(
            "http://localhost:8080/",
            "REQUEST_METHOD" => "GET",
            "PATH_INFO" => "/"
          )
        ), EXPECTED: "GET"
      },
      {
        REQUEST: Rack::Request.new(
          Rack::MockRequest.env_for(
            "http://localhost:8080/",
            "REQUEST_METHOD" => "DELETE",
            "PATH_INFO" => "/"
          )
        ), EXPECTED: "DELETE"
      },
      {
        REQUEST: Rack::Request.new(
          Rack::MockRequest.env_for(
            "http://localhost:8080/",
            "REQUEST_METHOD" => "PATCH",
            "PATH_INFO" => "/"
          )
        ), EXPECTED: "PATCH"
      },
      {
        REQUEST: Rack::Request.new(
          Rack::MockRequest.env_for(
            "http://localhost:8080/",
            "REQUEST_METHOD" => "PUT",
            "PATH_INFO" => "/"
          )
        ), EXPECTED: "PUT"
      },
      {
        REQUEST: Rack::Request.new(
          Rack::MockRequest.env_for(
            "http://localhost:8080/foo",
            "REQUEST_METHOD" => "POST"
          )
        ), EXPECTED: "POST.foo"
      },
      {
        REQUEST: Rack::Request.new(
          Rack::MockRequest.env_for(
            "http://localhost:8080/foo",
            "REQUEST_METHOD" => "GET"
          )
        ), EXPECTED: "GET.foo"
      },
      {
        REQUEST: Rack::Request.new(
          Rack::MockRequest.env_for(
            "http://localhost:8080/?a=b",
            "REQUEST_METHOD" => "GET"
          )
        ), EXPECTED: "GET"
      },
      {
        REQUEST: Rack::Request.new(
          Rack::MockRequest.env_for(
            "http://localhost:8080/en-us/api",
            "REQUEST_METHOD" => "GET"
          )
        ), EXPECTED: "GET.en_us.api"
      },
      {
        REQUEST: Rack::Request.new(
          Rack::MockRequest.env_for(
            "http://localhost:8080/en-us?view=3",
            "REQUEST_METHOD" => "GET"
          )
        ), EXPECTED: "GET.en_us"
      },
      {
        REQUEST: Rack::Request.new(
          Rack::MockRequest.env_for(
            "http://localhost:8080/en_us",
            "REQUEST_METHOD" => "GET"
          )
        ), EXPECTED: "GET.en_us"
      },
      {
        REQUEST: Rack::Request.new(
          Rack::MockRequest.env_for(
            "http://localhost:8080/til~de",
            "REQUEST_METHOD" => "GET"
          )
        ), EXPECTED: "GET.til_de"
      },
      {
        REQUEST: Rack::Request.new(
          Rack::MockRequest.env_for(
            "http://localhost:8080/__id",
            "REQUEST_METHOD" => "GET"
          )
        ), EXPECTED: "GET.__id"
      },
      {
        REQUEST: Rack::Request.new(
          Rack::MockRequest.env_for(
            "http://localhost:8080/__id",
            "REQUEST_METHOD" => "POST"
          )
        ), EXPECTED: "POST.__id"
      },
      {
        REQUEST: Rack::Request.new(
          Rack::MockRequest.env_for(
            "http://localhost:8080/v1",
            "REQUEST_METHOD" => "GET"
          )
        ), EXPECTED: "GET.v1"
      },
      {
        REQUEST: Rack::Request.new(
          Rack::MockRequest.env_for(
            "http://localhost:8080/dotted.endpoint",
            "REQUEST_METHOD" => "GET"
          )
        ), EXPECTED: "GET.dotted.endpoint"
      },
      {
        REQUEST: Rack::Request.new(
          Rack::MockRequest.env_for(
            "http://localhost:8080/a?dotted=q.u.e.r.y",
            "REQUEST_METHOD" => "GET"
          )
        ), EXPECTED: "GET.a"
      },
      {
        REQUEST: Rack::Request.new(
          Rack::MockRequest.env_for(
            "http://localhost:8080/numeric/123456/1",
            "REQUEST_METHOD" => "GET"
          )
        ), EXPECTED: "GET.numeric.123456.1"
      },
      {
        REQUEST: Rack::Request.new(
          Rack::MockRequest.env_for(
            "http://localhost:8080/Uppercase",
            "REQUEST_METHOD" => "GET"
          )
        ), EXPECTED: "GET.Uppercase"
      },
      {
        REQUEST: Rack::Request.new(
          Rack::MockRequest.env_for(
            "http://localhost:8080/api/:colons",
            "REQUEST_METHOD" => "GET"
          )
        ), EXPECTED: "GET.api.__colons"
      },
      {
        REQUEST: Rack::Request.new(
          Rack::MockRequest.env_for(
            "http://localhost:8080/api/:colons",
            "REQUEST_METHOD" => "POST"
          )
        ), EXPECTED: "POST.api.__colons"
      },
      { REQUEST: Rack::Request.new(
        Rack::MockRequest.env_for(
          "http://localhost:8080/api/:colons",
          "REQUEST_METHOD" => "DELETE"
        )
      ), EXPECTED: "DELETE.api.__colons" }
    ]
    data.each do |h|
      it "maps correctly #{h[:REQUEST].url}" do
        expect(described_class.execute(h[:REQUEST])).to eql(h[:EXPECTED])
      end
    end
  end

  context "when overwriting" do
    before do
      Aserto.with_policy_path_mapper do |request|
        method = request.request_method
        path = request.path_info

        "custom => #{method}.#{path}"
      end
    end

    it "allows registering another policy_path_mapper" do
      request = Rack::Request.new(
        Rack::MockRequest.env_for(
          "http://localhost:8080/",
          "REQUEST_METHOD" => "GET",
          "PATH_INFO" => "/"
        )
      )

      expect(described_class.execute(request)).to eql("custom => GET./")
    end
  end
end
