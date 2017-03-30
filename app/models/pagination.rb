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
end
