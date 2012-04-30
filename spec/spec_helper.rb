require File.join(File.dirname(__FILE__), '..', 'furry.rb')
require 'rack/test'

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.before(:each) {
    DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/furry_test.db")
    DataMapper.finalize
    Snippet.auto_migrate!
    Tag.auto_migrate!
    SnippetTag.auto_migrate!
  }
end
