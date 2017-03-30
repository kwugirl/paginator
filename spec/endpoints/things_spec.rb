require "spec_helper"

describe API::Endpoints::Things do
  include Rack::Test::Methods

  def app
    described_class
  end

  context "when no Range header was sent" do
    it "returns a JSON collection with Range response headers" do
      Thing.create! id: 123, name: "thing-123"

      get "/things"

      expect(last_response.headers["Content-Type"]).to eq("application/json")
      expect(last_response.headers["Content-Range"]).to eq("id 123..123")
      expect(last_response.headers["Next-Range"]).to eq("id ]123..; max=200")

      json = JSON.parse(last_response.body)

      expect(json).to be_kind_of(Array)
      expect(json).to include("id" => 123, "name" => "thing-123")
    end

    it "returns a JSON collection ordered by asc ID" do
      Thing.create! id: 300, name: "thing-300"
      Thing.create! id: 123, name: "thing-123"
      Thing.create! id: 124, name: "thing-124"
      expected_json = [
        {"id" => 123, "name" => "thing-123"},
        {"id" => 124, "name" => "thing-124"},
        {"id" => 300, "name" => "thing-300"}
      ]

      get "/things"
      json = JSON.parse(last_response.body)

      expect(json).to eq(expected_json)
      expect(last_response.headers["Content-Range"]).to eq("id 123..300")
      expect(last_response.headers["Next-Range"]).to eq("id ]300..; max=200")
    end

    it "returns a paginated JSON collection with at most 200 items" do
      starting_id = 101
      (starting_id..450).each do |num|
        Thing.create! id: num, name: "thing-#{num}"
      end
      expected_json = (starting_id...(starting_id + 200)).reduce([]) do |collection, num|
        collection << {"id" => num, "name" => "thing-#{num}"}
      end

      get "/things"
      json = JSON.parse(last_response.body)

      expect(json).to eq(expected_json)
      expect(last_response.headers["Content-Range"]).to eq("id 101..300")
      expect(last_response.headers["Next-Range"]).to eq("id ]300..; max=200")
    end
  end
end

# Range: <field> [[<exclusivity operator>]<start identifier>]]..[<end identifier>][; [max=<max number of results>], [order=[<asc|desc>]]
# minimal request header: `Range: <field> ..`
# Range: id ..
# Range: name ..

# making a request with a Range header that's just `Range: name ..` and then parsing it, therefore
# maybe have a Range object that has a helper, that when given the data result set, could generate its successor/Next-Range

# assumptions:
# when you get to the end, get back Next-Range that starts with final ID. also assume client-side could know to stop requesting when you got back fewer than what you'd requested for
# client should know that this is a paginated request, and that the default is 200 (this would be in an API doc)
