module API
  module Endpoints
    class Things < Base
      namespace "/things" do
        get do
          range_header = RangeHeader.parse(request.env["HTTP_RANGE"].to_s)

          max_page_size = 200
          order = :asc

          query = Thing.order(range_header.field => order).limit(max_page_size)
          if range_header.start_identifier
            things = query.where("#{range_header.field} >= #{range_header.start_identifier}")
          else
            things = query.all
          end

          headers 'Content-Range' => "#{range_header.field} #{things.first[range_header.field]}..#{things.last[range_header.field]}",
            'Next-Range' => "#{range_header.field} ]#{things.last[range_header.field]}..; max=#{max_page_size}"

          things.to_json
        end
      end

      class RangeHeader
        def self.parse(header)
          field = nil
          start_identifier = nil

          header_parts = /^(\S+) (\d*)..$/.match(header) || ""
          field = header_parts[1] unless header_parts[1].to_s.empty?
          start_identifier = header_parts[2] unless header_parts[2].to_s.empty?

          RangeHeader.new(field, start_identifier)
        end

        attr_reader :field, :start_identifier

        def initialize(field, start_identifier=nil)
          @field = field || "id"
          @start_identifier = start_identifier
        end
      end
    end
  end
end
