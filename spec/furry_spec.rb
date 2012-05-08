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

  it "should fail if the credentials are wrong" do
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
    last_request.url.should =~ /\/$/ 
  end

  it "should insert the snippet in the database" do
    lambda do
      post "/new", params = {
        :title => 'title',
        :body  => 'body',
        :tags  => '',
        :username => ENV['FURRY_USERNAME'],
        :password => ENV['FURRY_PASSWORD'],
      }
    end.should change(Snippet, :count).by(1)
  end

  it "should insert the snippet's tags in the database" do
    lambda do
      post "/new", params = {
        :title => 'title',
        :body  => 'body',
        :tags  => 'tag1, tag2',
        :username => ENV['FURRY_USERNAME'],
        :password => ENV['FURRY_PASSWORD'],
      }
    end.should change(Tag, :count).by(2)
  end

  it "should not re-insert a tag in the database" do
    lambda do
      post "/new", params = {
        :title => 'title',
        :body  => 'body',
        :tags  => 'hello',
        :username => ENV['FURRY_USERNAME'],
        :password => ENV['FURRY_PASSWORD'],
      }
    end.should change(Tag, :count).by(0)
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
    get '/a-page-that-does-not-exist'
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

describe "get /:slug/delete" do
  it "should show the snippet's delete page" do
    get '/hello/delete'
    last_response.should be_ok
  end

  it "should redirect to the homepage and display an alert if the snippet doesn't exist" do
    get '/a-page-that-does-not-exist/delete'
    last_response.should be_redirect
    follow_redirect!
    last_response.body.should include 'notice'
  end
end

describe "post /:slug/delete" do
  it "should fail and display an error message if the snippet doesn't exist" do
    post '/a-page-that-does-not-exist/delete'
    last_response.should be_redirect
    follow_redirect!
    last_response.body.should include 'notice'
  end

  it "should display an error message if the credentials are wrong" do
    post '/hello/delete', params = {
      :username => 'wrong-username',
      :username => 'wrong-password',
    }
    last_response.should be_redirect
    last_request.url.should include "hello/delete"
    follow_redirect!
    last_response.body.should include 'error'
    last_response.body.should include 'username'
    last_response.body.should include 'password'
  end

  it "should remove the snippet from the database" do
    lambda do
      post '/hello/delete', params = {
        :username => ENV['FURRY_USERNAME'],
        :password => ENV['FURRY_PASSWORD'],
      }
    end.should change(Snippet, :count).by(-1)
  end

  it "should redirect to the homepage" do
    post '/hello/delete', params = {
      :username => ENV['FURRY_USERNAME'],
      :password => ENV['FURRY_PASSWORD'],
    }
    last_response.should be_redirect
    follow_redirect!
    last_response.should be_ok
  end
end

describe "get /:slug/edit" do
  it "should display the edition page" do
    get "/hello/edit"
    last_response.should be_ok
    last_request.url.should include '/hello/edit'
  end

  it "should fail, redirect to the homepage and display an alert if the snippet doesn't exist" do
    get '/a-page-that-does-not-exist/edit'
    last_response.should be_redirect
    follow_redirect!
    last_response.should be_ok
    last_request.url.should =~ /\/$/
    last_response.body.should include 'notice'
  end
end

describe "post /:slug/edit" do
  it "should fail, redirect to the homepage and display an alert if the snippet doesn't exist" do
    post '/a-page-that-does-not-exist/edit'
    last_response.should be_redirect
    follow_redirect!
    last_request.url.should =~ /\/$/
    last_response.body.should include 'notice'
  end

  it "should update the item's title" do
    snippet = Snippet.first(:title => 'hello')
    post "/hello/edit", params = {
      :title => 'goodbye!',
      :body  => 'goodbye world',
      :username => ENV['FURRY_USERNAME'],
      :password => ENV['FURRY_PASSWORD'],
    }
    snippet.reload.title.should == 'goodbye!'
  end

  it "should update the item's slug" do
    snippet = Snippet.first(:title => 'hello')
    post "/hello/edit", params = {
      :title => 'goodbye!',
      :body  => 'goodbye world',
      :username => ENV['FURRY_USERNAME'],
      :password => ENV['FURRY_PASSWORD'],
    }
    snippet.reload.slug.should == 'goodbye'
  end

  it "should update the item's tags" do
    snippet = Snippet.first(:title => 'hello')
    post "/hello/edit", params = {
      :title => 'goodbye!',
      :body  => 'goodbye world',
      :tags  => 'goodbye, hello',
      :username => ENV['FURRY_USERNAME'],
      :password => ENV['FURRY_PASSWORD'],
    }
    snippet.reload.tags.count.should == 2
    snippet.reload.tags[1].tag.should == 'goodbye'
    snippet.reload.tags[0].tag.should == 'hello'
  end

  it "should update the item's body" do
    snippet = Snippet.first(:title => 'hello')
    post "/hello/edit", params = {
      :title => 'goodbye!',
      :body  => 'goodbye world',
      :username => ENV['FURRY_USERNAME'],
      :password => ENV['FURRY_PASSWORD'],
    }
    snippet.reload.body.should == 'goodbye world'
  end

  it "should redirect to the homepage and display an alert" do
    post "/hello/edit", params = {
      :title => 'goodbye',
      :body  => 'goodbye world',
      :username => ENV['FURRY_USERNAME'],
      :password => ENV['FURRY_PASSWORD'],
    }
    last_response.should be_redirect
    follow_redirect!
    last_request.url.should =~ /\/$/
    last_response.body.should include 'success'
  end

  it "should fail if the password is wrong" do
    post "/hello/edit", params = {
      :title => 'goodbye',
      :body  => 'goodbye world',
      :username => 'wrong-username',
      :username => 'wrong-password',
    }
    last_request.post?.should be_true
    last_response.body.should include 'error'
    last_response.body.should include 'username'
    last_response.body.should include 'password'
  end

  it "should fail if the title is empty" do
    post "/hello/edit", params = {
      :title => '',
      :body  => 'goodbye world',
      :username => ENV['FURRY_USERNAME'],
      :password => ENV['FURRY_PASSWORD'],
    }
    last_request.post?.should be_true
    last_response.body.should include 'error'
  end

  it "should fail if the body is empty" do
    post "/hello/edit", params = {
      :title => 'goodbye',
      :body  => '',
      :username => ENV['FURRY_USERNAME'],
      :password => ENV['FURRY_PASSWORD'],
    }
    last_request.post?.should be_true
    last_response.body.should include 'error'
  end
end
