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

  it "returns a JSON collection paginated on the specified field" do
    Thing.create! id: 1, name: "thing-300"
    Thing.create! id: 2, name: "thing-123"
    Thing.create! id: 3, name: "thing-124"

    specified_field = "name"
    expected_json = [
      {"name" => "thing-123", "id" => 2},
      {"name" => "thing-124", "id" => 3},
      {"name" => "thing-300", "id" => 1}
    ]

    header "Range", "#{specified_field} .."
    get "/things"
    json = JSON.parse(last_response.body)

    expect(json).to eq(expected_json)
    expect(last_response.headers["Content-Range"]).to eq("#{specified_field} thing-123..thing-300")
    expect(last_response.headers["Next-Range"]).to eq("#{specified_field} ]thing-300..; max=200")
  end

  it "returns a JSON collection limited to specified page size with precedence over end identifier" do
    Thing.create! id: 300, name: "thing-300"
    Thing.create! id: 1, name: "thing-1"
    Thing.create! id: 200, name: "thing-200"

    page_size = 2
    end_identifier = 500
    expected_json = [
      {"id" => 1, "name" => "thing-1"},
      {"id" => 200, "name" => "thing-200"}
    ]

    header "Range", "id 1..#{end_identifier}; max=#{page_size}"
    get "/things"
    json = JSON.parse(last_response.body)

    expect(json).to eq(expected_json)
    expect(last_response.headers["Next-Range"]).to eq("id ]200..; max=#{page_size}")
  end
end
