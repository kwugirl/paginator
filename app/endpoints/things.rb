module API
  module Endpoints
    class Things < Base
      namespace "/things" do
        get do
          range_header = request.env["HTTP_RANGE"]

          # TODO: actually parse and paginate
          field = "id"

          things = Thing.all
          headers 'Content-Range' => "#{field} #{things.first[field]}..#{things.last[field]}"

          things.to_json
        end
      end
    end
  end
end
