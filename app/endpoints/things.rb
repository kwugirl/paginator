require 'app/models/pagination'

module API
  module Endpoints
    class Things < Base
      include Pagination

      namespace "/things" do
        get do
          range_header = request.env["HTTP_RANGE"] || RangeHeader.new

          things = Thing.all.order(range_header.field => range_header.ordering).limit(range_header.page_size)
          headers 'Content-Range' => "#{range_header.field} #{things.first[range_header.field]}..#{things.last[range_header.field]}",
            'Next-Range' => "#{range_header.field} ]#{things.last[range_header.field]}..; max=#{range_header.page_size}"

          things.to_json
        end
      end
    end
  end
end
