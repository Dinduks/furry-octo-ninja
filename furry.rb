require 'bundler'
Bundler.require

require './models/snippet.rb'
require './models/tag.rb'
require './models/snippettag.rb'

def get_formatted_text(string)
  tmp_dir = ENV['TMP_DIR'] || '/tmp/'
  File.open("#{tmp_dir}furry.md", 'w')
  GitHub::Markup.render("#{tmp_dir}furry.md", string)
end

configure do
  set :erb,    :trim => '-'
  set :config, YAML.load_file('config.yml')
  settings.config['username'] = ENV['FURRY_USERNAME']
  settings.config['password'] = ENV['FURRY_PASSWORD']
  settings.config['tmp_dir']  = ENV['TMP_DIR']
  enable :sessions

  DataMapper::setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/furry.db")
  DataMapper.finalize
  Snippet.auto_upgrade!
  Tag.auto_upgrade!
  SnippetTag.auto_upgrade!
end

before do
  @alerts = (@alerts ||= []) | (session[:alerts] ||= [])
  session[:alerts] = []
end

get '/' do
  @snippets = Snippet.all(:order => :created_at.desc)
  erb :index, :locals => {
    :site_name  => settings.config['site_name'],
    :author     => settings.config['author_name'],
  }
end

get '/new' do
  @snippet = Snippet.new
  erb :new, :locals => {
    :site_name => settings.config['site_name'],
    :snippet   => @snippet,
    :tags      => '',
    :action    => 'Add',
  }
end

post '/new' do
  @snippet = Snippet.new
  @snippet.title = params[:title]
  @snippet.slug  = params[:title].to_url
  @snippet.body  = params[:body]
  @tags          = params[:tags]

  @alerts = []
  @alerts << { type: :error, message: 'Fill in the title field!' } if params[:title].to_s.empty?
  @alerts << { type: :error, message: 'Fill in the content field!' } if params[:body].to_s.empty?
  unless params[:password] == settings.config['password'] and params[:password] == settings.config['password']
    @alerts << { type: :error, message: 'Wrong username or password!' }
  end

  unless @alerts.empty?
    return erb :new, :locals => {
      :snippet   => @snippet,
      :tags      => @tags,
      :site_name => settings.config['site_name'],
      :action    => 'New'
    }
  end

  @snippet.add_tags params[:tags] unless params[:tags].to_s.empty?

  @snippet.save
  session[:alerts] << { type: :success, message: 'Snippet successfully added!' }
  redirect '/'
end

get '/get-formatted-text' do
  get_formatted_text params[:body]
end

get '/get-slug' do
  params[:string].to_url
end

get '/:slug/delete' do
  snippet = Snippet.first(:slug => params[:slug])
  if snippet.nil?
    session[:alerts] << { type: :notice,  message: "This snippet doesn't exist!" }
    redirect '/'
  else
    erb :delete, :locals => {
      :snippet   => snippet,
      :site_name => settings.config['site_name']
    }
  end
end

post '/:slug/delete' do
  snippet = Snippet.first(:slug => params[:slug])
  if snippet.nil?
    session[:alerts] << { type: :notice,  message: "This snippet doesn't exist!" }
  else
    unless params[:password] == settings.config['password'] and params[:password] == settings.config['password']
      session[:alerts] << { type: :error, message: 'Wrong username or password!' }
      redirect "/#{params[:slug]}/delete"
    end
    session[:alerts] << { type: :success, message: "Snippet successfully deleted!" }
    snippet.destroy
  end
  redirect '/'
end

get '/:slug/edit' do
  snippet = Snippet.first(:slug => params[:slug])
  if snippet.nil?
    session[:alerts] << { type: :notice,  message: "This snippet doesn't exist!" }
    redirect '/'
  else
    tags = ''
    snippet.tags.each do |tag|
      tags += tag.tag
      tags += ', ' unless tag == snippet.tags[-1]
    end
    erb :new, :locals => {
      :snippet   => snippet,
      :tags      => tags,
      :site_name => settings.config['site_name'],
      :action    => 'Edit',
    }
  end
end

post '/:slug/edit' do
  snippet = Snippet.first(:slug => params[:slug])

  if snippet.nil?
    session[:alerts] << { type: :notice,  message: "This snippet doesn't exist!" }
    redirect '/'
  end

  @alerts = []

  # title validation
  unless params[:title].to_s.empty?
    snippet.title = params[:title]
    snippet.slug  = params[:title].to_url
  else
    @alerts << { type: :error, message: 'The title field cannot be empty!' }
  end

  # body validation
  unless params[:body].to_s.empty?
    snippet.body  = params[:body]
  else
    @alerts << { type: :error, message: "The snippet's body cannot be empty!" }
  end

  # credentials validation
  unless params[:password] == settings.config['password'] and params[:password] == settings.config['password']
    @alerts << { type: :error, message: 'Wrong username or password!' }
  end

  # if there's any alert
  unless @alerts.empty?
    return erb :new, :locals => {
      :snippet   => snippet,
      :tags      => @tags,
      :site_name => settings.config['site_name'],
      :action    => 'Edit',
    }
  end

  if params[:tags].to_s.empty?
    snippet.tags = []
  else
    snippet.add_tags params[:tags] unless params[:tags].to_s.empty?
  end

  snippet.save
  session[:alerts] << { type: :success, message: "The snippet was successfully updated!" }
  redirect '/'
end

get '/:slug' do
  @snippet = Snippet.first(:slug => params[:slug])
  if @snippet.nil?
    session[:alerts] << { type: :notice, message: 'Snippet not found!' }
    redirect '/'
  end
  @snippet.body = get_formatted_text @snippet.body
  erb :show, :locals => {
    :snippet   => @snippet,
    :site_name => settings.config['site_name']
  }
end

get '/tag/:tag' do
  @tag = Tag.first(:tag => params[:tag])
  erb :show_tag, :locals => {
    :tag       => @tag,
    :site_name => settings.config['site_name']
  }
end
