module Pagination
  class RangeHeader
    attr_reader :field, :page_size, :ordering, :start_identifier, :end_identifier, :exclusive_start

    DEFAULT_FIELD = "id"
    DEFAULT_PAGE_SIZE = 200
    DEFAULT_ORDERING = :asc

    def initialize(field: DEFAULT_FIELD, page_size: DEFAULT_PAGE_SIZE, ordering: DEFAULT_ORDERING,
      start_identifier: nil, end_identifier: nil, exclusive_start: false)
      @field = field
      @page_size = page_size
      @ordering = ordering
      @start_identifier = start_identifier
      @end_identifier = end_identifier
      @exclusive_start = exclusive_start
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
      unless @header.ordering == RangeHeader::DEFAULT_ORDERING
        ordering = ", order=#{@header.ordering}"
      end

      "#{@header.field} ]#{@results.last[@header.field]}..; max=#{@header.page_size}#{ordering}"
    end
  end

  def parse_range_request_header(header)
    return RangeHeader.new unless header

    params = {}

    field, rest_of_header = header.split(" ", 2)
    params[:field] = field

    start_identifier, rest_of_header = rest_of_header.split("..", 2)
    params[:exclusive_start] = true if start_identifier.start_with?("]")
    params[:start_identifier] = start_identifier.gsub(/^\[|\]/,'') unless start_identifier.blank?

    end_identifier, rest_of_header = rest_of_header.split("; ", 2)
    params[:end_identifier] = end_identifier unless end_identifier.blank?

    if rest_of_header
      match_for_page_size = rest_of_header.match(/max=(\d+)/)
      page_size = match_for_page_size[1] if match_for_page_size
      params[:page_size] = page_size.to_i if page_size

      match_for_ordering = rest_of_header.match(/order=(desc)/)
      params[:ordering] = :desc if match_for_ordering
    end

    RangeHeader.new(params)
  end
end
