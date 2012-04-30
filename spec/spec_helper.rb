require File.join(File.dirname(__FILE__), '..', 'furry.rb')
require 'rack/test'

set :environment, :test

RSpec.configure do |config|
  config.include Rack::Test::Methods
end
