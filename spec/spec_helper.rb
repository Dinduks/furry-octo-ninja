require 'rack/test'
require 'simplecov'
SimpleCov.start
require File.join(File.dirname(__FILE__), '..', 'furry.rb')

RSpec.configure do |config|
  config.include Rack::Test::Methods

  config.before(:each) {
    DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/furry_test.db")
    DataMapper.finalize
    Snippet.auto_migrate!
    Tag.auto_migrate!
    SnippetTag.auto_migrate!

    # Create some "fixture" data in the db
    tag10 = Tag.new(:tag => 'tag10')
    tag20 = Tag.new(:tag => 'tag20')
    tag10.save
    tag20.save

    s = Snippet.new(
      :title => 'hello',
      :slug  => 'hello',
      :body  => 'hello world!'
    )
    s.tags << tag10
    s.tags << tag20
    s.save

    Tag.new(:tag => 'hello').save
  }
end
