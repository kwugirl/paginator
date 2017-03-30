module Pagination
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
  end

  class Paginator
    def initialize(results, range_request_header)
      @results = results
      @range_request_header = range_request_header
    end

    def range_response_headers
      {'Next-Range' => next_range_header}
    end

    private

    def next_range_header
      "#{@range_request_header.field} ]#{@results.last[@range_request_header.field]}..; max=#{@range_request_header.page_size}"
    end
  end
end
