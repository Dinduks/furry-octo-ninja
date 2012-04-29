require './furry.rb'
require 'test/unit'
require 'rack/test'

class GetNewTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_it_works
    get '/'
    assert last_response.ok?
  end
end
