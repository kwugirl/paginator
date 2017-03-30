require 'app/models/pagination'

module API
  module Endpoints
    class Things < Base
      include Pagination

      namespace "/things" do
        get do
          range_header = request.env["HTTP_RANGE"] || RangeHeader.new

          things = Thing.all.order(range_header.field => range_header.ordering).limit(range_header.page_size)
          paginator = Paginator.new(things, range_header)

          headers paginator.response_headers
          things.to_json
        end
      end
    end
  end
end
