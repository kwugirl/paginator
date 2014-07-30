require "json"
require "sequel"
require "sinatra"

#
# = Examples
#
# To encode JSON:
#
#   JSON.generate([1, 2, 3])
#
# Get a query parameter:
#
#   params[:max]
#
# Get a request header:
#
#   request.env["HTTP_RANGE"]
#
# Set a response header:
#
#   headers["Range"] = "hello"
#
# Connect to a database using Sequel:
#
#   DB = Sequel.connect(ENV["DATBASE_URL"])
#   DB[:items].limit(5).all
#

get "/" do
  "Hello, world"
end
