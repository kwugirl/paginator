module Pagination
  # Range: <field> [[<exclusivity operator>]<start identifier>]]..[<end identifier>][; [max=<max number of results>], [order=[<asc|desc>]]
  class RangeHeader
    attr_reader :field, :page_size, :ordering

    DEFAULT_FIELD = "id"
    DEFAULT_PAGE_SIZE = 200
    DEFAULT_ORDERING = :asc

    def initialize(field=DEFAULT_FIELD, page_size=DEFAULT_PAGE_SIZE, ordering=DEFAULT_ORDERING)
      @field = field
      @page_size = page_size
      @ordering = ordering
    end

    def attributes
      all_attributes = {}
      instance_variables.map do |ivar|
        all_attributes[ivar] = instance_variable_get(ivar)
      end
      all_attributes
    end

    def ==(other_range_header)
      self.attributes == other_range_header.attributes
    end

    def query_for(ar_model)
      ar_model.all.order(field => ordering).limit(page_size)
    end
  end

  class Paginator
    def initialize(results, header)
      @results = results
      @header = header
    end

    def response_headers
      {
        'Content-Range' => content_range,
        'Next-Range' => next_range
      }
    end

    private

    def content_range
      "#{@header.field} #{@results.first[@header.field]}..#{@results.last[@header.field]}"
    end

    def next_range
      "#{@header.field} ]#{@results.last[@header.field]}..; max=#{@header.page_size}"
    end
  end

  def parse_range_request_header(header)
    field = header.split(" ").first
    RangeHeader.new(field)
  end
end
