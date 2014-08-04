require "minitest"
require "minitest/autorun"
require "minitest/spec"
require "rack/test"

require "app"

describe "Paginated App" do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it "says hello" do
    get "/"
    assert_equal 200, last_response.status
    assert_match /hello/i, last_response.body
  end
end
