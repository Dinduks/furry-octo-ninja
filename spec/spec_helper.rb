require File.join(File.dirname(__FILE__), '..', 'furry.rb')
require 'rack/test'

RSpec.configure do |config|
  config.include Rack::Test::Methods
  settings.admin['username'] = 'username'
  settings.admin['password'] = 'password'

  config.before(:each) {
    DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/furry_test.db")
    DataMapper.finalize
    Snippet.auto_migrate!
    Tag.auto_migrate!
    SnippetTag.auto_migrate!

    # Create some "fixture" data in the db
    Snippet.new(
      :title => 'hello',
      :slug  => 'hello',
      :body  => 'hello world!'
    ).save
    Tag.new(:tag => 'hello').save
  }
end
