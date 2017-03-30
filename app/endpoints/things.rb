module API
  module Endpoints
    class Things < Base
      namespace "/things" do
        get do
          range_header = RangeHeader.parse(request.env["HTTP_RANGE"].to_s)

          query = Thing.order(range_header.field => range_header.order).limit(range_header.page_size).all
          if range_header.start_identifier
            if range_header.inclusive
              query = query.where("#{range_header.field} >= #{range_header.start_identifier}")
            else
              query = query.where("#{range_header.field} > #{range_header.start_identifier}")
            end
          end
          if range_header.end_identifier
            query = query.where("#{range_header.field} < #{range_header.end_identifier}")
          end
          things = query

          next_range = "#{range_header.field} ]#{things.last[range_header.field]}..; max=#{range_header.page_size}"
          next_range += ", order=#{range_header.order}" unless range_header.order == RangeHeader::DEFAULT_ORDER
          headers 'Content-Range' => "#{range_header.field} #{things.first[range_header.field]}..#{things.last[range_header.field]}",
            'Next-Range' => next_range

          things.to_json
        end
      end

      class RangeHeader
        def self.parse(header)
          field = nil
          start_identifier = nil
          end_identifier = nil
          inclusive = true
          page_size = nil
          order = nil

          header_part_one, header_part_two = header.split("; ")

          header_part_one = /^(\S+) (\[|\])?(.*)\.\.(.*)/.match(header_part_one) || ""

          field = header_part_one[1] unless header_part_one[1].to_s.empty?
          inclusive = false if !header_part_one[2].to_s.empty? && header_part_one[2] == "]"
          start_identifier = header_part_one[3] unless header_part_one[3].to_s.empty?
          end_identifier = header_part_one[4] unless header_part_one[4].to_s.empty?

          if header_part_two
            page_size = /max=(\d+)/.match(header_part_two)[1] if /max=(\d+)/.match(header_part_two)
            order = /order=(desc|asc)/.match(header_part_two)[1] if /order=(desc|asc)/.match(header_part_two)
          end

          RangeHeader.new(field, start_identifier, end_identifier, inclusive, page_size, order)
        end

        attr_reader :field, :start_identifier, :end_identifier, :inclusive, :page_size, :order
        DEFAULT_ORDER = "asc"

        def initialize(field, start_identifier=nil, end_identifier=nil, inclusive=true, page_size=200, order=DEFAULT_ORDER)
          @field = field || "id"
          @start_identifier = start_identifier
          @end_identifier = end_identifier
          @inclusive = inclusive
          @page_size = page_size || 200
          @order = order || DEFAULT_ORDER
        end
      end
    end
  end
end
