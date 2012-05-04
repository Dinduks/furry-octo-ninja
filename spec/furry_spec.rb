# encoding: utf-8

require 'spec_helper'

def app
  Sinatra::Application
end

describe "get /" do
  it "should load the homepage" do
    get "/"
    last_response.should be_ok
  end
end

describe "get /404" do
  it "should load the 404 error page" do
    get "/404"
    last_response.should be_ok
  end
end

describe "get /new" do
  it "should display the add page" do
    get "/new"
    last_response.should be_ok
  end
end

describe "post /new" do
  it "should fail if the fields are empty" do
    post "/new", params = {
      :title => '',
      :body  => '',
      :tags  => '',
    }
    last_request.post?.should be_true
    last_response.body.should include "alert-error"
  end

  it "should fail because of wrong credentials" do
    post "/new", params = {
      :title    => 'body',
      :body     => 'title',
      :username => 'wrong-username',
      :username => 'wrong-password',
    }
    last_request.post?.should be_true
    last_response.body.should include "alert-error"
  end

  it "should redirect to the homepage" do
    post "/new", params = {
      :title    => 'title',
      :body     => 'body',
      :tags     => '',
      :username => ENV['FURRY_USERNAME'],
      :password => ENV['FURRY_PASSWORD'],
    }
    last_response.should be_redirect
    follow_redirect!
    last_request.url.should include '/'
  end

  it "should insert the snippet and its tags in the database" do
    lambda do
      post "/new", params = {
        :title => 'title',
        :body  => 'body',
        :tags  => 'hello, world',
      }
    end.should {
      change(Snippet, :count).by(1)
      change(Tag, :count).by(2)
    }
  end
end

describe "get /get-formatted-text" do
  it "should return the formatted text" do
    get "/get-formatted-text", params = {
      :body => "# Hello"
    }
    last_response.body.should include "<h1>Hello</h1>"
  end
end

describe "get /get-slug" do
  it "should return the slugified string" do
    get "/get-slug", params = {
      :string => "Åh, räksmörgåsar!"
    }
    last_response.body.should == "ah-raksmorgasar"
  end
end

describe "get /:slug" do
  it "should show the snippet's page" do
    get "/hello"
    last_response.should be_ok
  end

  it "should redirect to /404 if the snippet doesn't exist" do
    get '/a-page-that-does-no-exist'
    last_response.should be_redirect
    follow_redirect!
    last_request.url.should include '/404'
  end
end

describe "get /tag/hello" do
  it "should load the tag's page" do
    get "/tag/hello"
    last_response.should be_ok
  end
end
