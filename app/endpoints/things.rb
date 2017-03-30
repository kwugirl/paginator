module API
  module Endpoints
    class Things < Base
      namespace "/things" do
        get do
          range_header = RangeHeader.parse(request.env["HTTP_RANGE"].to_s)

          max_page_size = 200
          order = :asc

          things = Thing.all.order(range_header.field => order).limit(max_page_size)
          headers 'Content-Range' => "#{range_header.field} #{things.first[range_header.field]}..#{things.last[range_header.field]}",
            'Next-Range' => "#{range_header.field} ]#{things.last[range_header.field]}..; max=#{max_page_size}"

          things.to_json
        end
      end

      class RangeHeader
        def self.parse(header)
          field = nil

          header_parts = /^(\S+) (\d*)..$/.match(header) || ""
          field = header_parts[1] unless header_parts[1].to_s.empty?

          RangeHeader.new(field)
        end

        attr_reader :field

        def initialize(field)
          @field = field || "id"
        end
      end
    end
  end
end
