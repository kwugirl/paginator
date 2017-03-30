module API
  module Endpoints
    class Things < Base
      namespace "/things" do
        get do
          range_header = request.env["HTTP_RANGE"]

          # TODO: actually parse and paginate
          field = "id"
          max_page_size = 200
          order = :asc

          things = Thing.all.order(field => order).limit(max_page_size)
          headers 'Content-Range' => "#{field} #{things.first[field]}..#{things.last[field]}",
            'Next-Range' => "#{field} ]#{things.last[field]}..; max=#{max_page_size}"

          things.to_json
        end
      end
    end
  end
end
