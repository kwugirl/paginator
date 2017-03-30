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
  end
end

# Range: <field> [[<exclusivity operator>]<start identifier>]]..[<end identifier>][; [max=<max number of results>], [order=[<asc|desc>]]
# minimal request header: `Range: <field> ..`
# Range: id ..
# Range: name ..
# defaults for when no Range header was specified at all:
# * field: id
# * start with 1
# * max page size of 200
# * order: asc
# * numbers in the response headers based entirely on the data that's being sent back. consider that rows may have been deleted, IDs may be sparse
# * still returns a Content-Range header describing the precise range of the response (ex. Content-Range: id 5..10) - 2 cases, for if you have fewer or more than the max page size
# * still returns a Next-Range header for how to request the following page (ex. Next-Range: id ]10..; max=200)

# next tests: ordering, max page size (need to put in 200+ objects into test database)
# making a request with a Range header that's just `Range: name ..` and then parsing it, therefore
# maybe have a Range object that has a helper, that when given the data result set, could generate its successor/Next-Range

# assumptions:
# when you get to the end, get back Next-Range that starts with final ID. also assume client-side could know to stop requesting when you got back fewer than what you'd requested for
# client should know that this is a paginated request, and that the default is 200 (this would be in an API doc)
