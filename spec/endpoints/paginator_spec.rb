require "spec_helper"
require "app/models/pagination"

describe Pagination do
  include Rack::Test::Methods
  include Pagination

  it "should generate expected Next-Range response header given default range request header and query results" do

    range_request_header = Pagination::RangeHeader.new
    results = [{Pagination::RangeHeader::DEFAULT_FIELD => 1}, {Pagination::RangeHeader::DEFAULT_FIELD => 2}]
    paginator = Pagination::Paginator.new(results, range_request_header)

    expected_next_range_response_header = {'Next-Range' =>
      "#{Pagination::RangeHeader::DEFAULT_FIELD} ]#{results.last[Pagination::RangeHeader::DEFAULT_FIELD]}..; max=#{Pagination::RangeHeader::DEFAULT_PAGE_SIZE}"}

    expect(paginator.range_response_headers).to include(expected_next_range_response_header)
  end
end
