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
        ), EXPECTED: "tp.GET"
      },
      {
        REQUEST: Rack::Request.new(
          Rack::MockRequest.env_for(
            "http://localhost:8080/",
            "REQUEST_METHOD" => "DELETE",
            "PATH_INFO" => "/"
          )
        ), EXPECTED: "tp.DELETE"
      },
      {
        REQUEST: Rack::Request.new(
          Rack::MockRequest.env_for(
            "http://localhost:8080/",
            "REQUEST_METHOD" => "PATCH",
            "PATH_INFO" => "/"
          )
        ), EXPECTED: "tp.PATCH"
      },
      {
        REQUEST: Rack::Request.new(
          Rack::MockRequest.env_for(
            "http://localhost:8080/",
            "REQUEST_METHOD" => "PUT",
            "PATH_INFO" => "/"
          )
        ), EXPECTED: "tp.PUT"
      },
      {
        REQUEST: Rack::Request.new(
          Rack::MockRequest.env_for(
            "http://localhost:8080/foo",
            "REQUEST_METHOD" => "POST"
          )
        ), EXPECTED: "tp.POST.foo"
      },
      {
        REQUEST: Rack::Request.new(
          Rack::MockRequest.env_for(
            "http://localhost:8080/foo",
            "REQUEST_METHOD" => "GET"
          )
        ), EXPECTED: "tp.GET.foo"
      },
      {
        REQUEST: Rack::Request.new(
          Rack::MockRequest.env_for(
            "http://localhost:8080/?a=b",
            "REQUEST_METHOD" => "GET"
          )
        ), EXPECTED: "tp.GET"
      },
      {
        REQUEST: Rack::Request.new(
          Rack::MockRequest.env_for(
            "http://localhost:8080/en-us/api",
            "REQUEST_METHOD" => "GET"
          )
        ), EXPECTED: "tp.GET.en_us.api"
      },
      {
        REQUEST: Rack::Request.new(
          Rack::MockRequest.env_for(
            "http://localhost:8080/en-us?view=3",
            "REQUEST_METHOD" => "GET"
          )
        ), EXPECTED: "tp.GET.en_us"
      },
      {
        REQUEST: Rack::Request.new(
          Rack::MockRequest.env_for(
            "http://localhost:8080/en_us",
            "REQUEST_METHOD" => "GET"
          )
        ), EXPECTED: "tp.GET.en_us"
      },
      {
        REQUEST: Rack::Request.new(
          Rack::MockRequest.env_for(
            "http://localhost:8080/til~de",
            "REQUEST_METHOD" => "GET"
          )
        ), EXPECTED: "tp.GET.til_de"
      },
      {
        REQUEST: Rack::Request.new(
          Rack::MockRequest.env_for(
            "http://localhost:8080/__id",
            "REQUEST_METHOD" => "GET"
          )
        ), EXPECTED: "tp.GET.__id"
      },
      {
        REQUEST: Rack::Request.new(
          Rack::MockRequest.env_for(
            "http://localhost:8080/__id",
            "REQUEST_METHOD" => "POST"
          )
        ), EXPECTED: "tp.POST.__id"
      },
      {
        REQUEST: Rack::Request.new(
          Rack::MockRequest.env_for(
            "http://localhost:8080/v1",
            "REQUEST_METHOD" => "GET"
          )
        ), EXPECTED: "tp.GET.v1"
      },
      {
        REQUEST: Rack::Request.new(
          Rack::MockRequest.env_for(
            "http://localhost:8080/dotted.endpoint",
            "REQUEST_METHOD" => "GET"
          )
        ), EXPECTED: "tp.GET.dotted.endpoint"
      },
      {
        REQUEST: Rack::Request.new(
          Rack::MockRequest.env_for(
            "http://localhost:8080/a?dotted=q.u.e.r.y",
            "REQUEST_METHOD" => "GET"
          )
        ), EXPECTED: "tp.GET.a"
      },
      {
        REQUEST: Rack::Request.new(
          Rack::MockRequest.env_for(
            "http://localhost:8080/numeric/123456/1",
            "REQUEST_METHOD" => "GET"
          )
        ), EXPECTED: "tp.GET.numeric.123456.1"
      },
      {
        REQUEST: Rack::Request.new(
          Rack::MockRequest.env_for(
            "http://localhost:8080/Uppercase",
            "REQUEST_METHOD" => "GET"
          )
        ), EXPECTED: "tp.GET.Uppercase"
      },
      {
        REQUEST: Rack::Request.new(
          Rack::MockRequest.env_for(
            "http://localhost:8080/api/:colons",
            "REQUEST_METHOD" => "GET"
          )
        ), EXPECTED: "tp.GET.api.__colons"
      },
      {
        REQUEST: Rack::Request.new(
          Rack::MockRequest.env_for(
            "http://localhost:8080/api/:colons",
            "REQUEST_METHOD" => "POST"
          )
        ), EXPECTED: "tp.POST.api.__colons"
      },
      { REQUEST: Rack::Request.new(
        Rack::MockRequest.env_for(
          "http://localhost:8080/api/:colons",
          "REQUEST_METHOD" => "DELETE"
        )
      ), EXPECTED: "tp.DELETE.api.__colons" }
    ]
    data.each do |h|
      it "maps correctly #{h[:REQUEST].url}" do
        expect(described_class.execute("tp", h[:REQUEST])).to eql(h[:EXPECTED])
      end
    end
  end

  context "when overwriting" do
    before do
      Aserto.with_policy_path_mapper do |policy_root, request|
        method = request.request_method
        path = request.path_info

        "custom => #{policy_root}.#{method}.#{path}"
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

      expect(described_class.execute("test", request)).to eql("custom => test.GET./")
    end
  end
end
