require 'rack/test'
require 'simplecov'
SimpleCov.start
require File.join(File.dirname(__FILE__), '..', 'furry.rb')
require 'factory_girl'
require 'factories.rb'

RSpec.configure do |config|
  config.include Rack::Test::Methods

  config.before(:each) {
    DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/furry_test.db")
    DataMapper.finalize
    Snippet.auto_migrate!
    Tag.auto_migrate!
    SnippetTag.auto_migrate!

    @basic_snippet = FactoryGirl.create(:basic_snippet)
    @basic_tag     = FactoryGirl.create(:basic_tag)
  }
end
