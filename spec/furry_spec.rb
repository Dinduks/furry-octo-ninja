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

  it "should redirect to the homepage" do
    post "/new", params = {
      :title => 'title',
      :body  => 'body',
      :tags  => '',
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
