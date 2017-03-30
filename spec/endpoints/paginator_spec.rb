require "spec_helper"
require "app/models/pagination"

describe Pagination do
  include Rack::Test::Methods
  include Pagination

  it "should generate expected range response headers given default range request header and query results" do

    range_request_header = Pagination::RangeHeader.new
    results = [{Pagination::RangeHeader::DEFAULT_FIELD => 1}, {Pagination::RangeHeader::DEFAULT_FIELD => 2}]
    paginator = Pagination::Paginator.new(results, range_request_header)

    expected_range_response_headers = {
      'Content-Range' => "#{Pagination::RangeHeader::DEFAULT_FIELD} #{results.first[Pagination::RangeHeader::DEFAULT_FIELD]}..#{results.last[Pagination::RangeHeader::DEFAULT_FIELD]}",
      'Next-Range' => "#{Pagination::RangeHeader::DEFAULT_FIELD} ]#{results.last[Pagination::RangeHeader::DEFAULT_FIELD]}..; max=#{Pagination::RangeHeader::DEFAULT_PAGE_SIZE}"
    }

    expect(paginator.response_headers).to include(expected_range_response_headers)
  end

  it "should parse minimal range request header with field" do
    request_header = "name .."
    expected = Pagination::RangeHeader.new(field: "name")

    expect(parse_range_request_header(request_header)).to be == expected
  end

  it "should parse range request header with start identifier" do
    # Range: id 1..
  end

  it "should parse range request header with numeric start and end identifiers" do
    # Range: id 1..5
  end

  it "should parse range request header with nonnumeric start and end identifiers" do
    # Range: name ]my-app-001..my-app-999
  end

  it "should parse range request header with exclusivity operator" do
    # Range: id ]5..
  end

  it "should parse range request header with page size" do
    # Range: id 1..; max=5
  end

  it "should parse range request header with ordering" do
    # Range: id 1..; order=desc
  end

  it "should parse range request header with all elements" do
    # Range: id ]5..10; max=5, order=desc
    # Range: name ]my-app-001..my-app-999; max=10, order=asc
  end
end
