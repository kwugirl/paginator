module API
  module Endpoints
    class Things < Base
      namespace "/things" do
        get do
          range_header = request.env["HTTP_RANGE"] || RangeHeader.new

          max_page_size = 200
          order = :asc

          things = Thing.all.order(range_header.field => order).limit(max_page_size)
          headers 'Content-Range' => "#{range_header.field} #{things.first[range_header.field]}..#{things.last[range_header.field]}",
            'Next-Range' => "#{range_header.field} ]#{things.last[range_header.field]}..; max=#{max_page_size}"

          things.to_json
        end
      end

      class RangeHeader
        attr_reader :field

        def initialize(field="id")
          @field = field
        end
      end
    end
  end
end
