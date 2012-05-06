require 'sinatra/reloader'
require 'sinatra'
require 'rubygems'
require 'data_mapper'
require 'yaml'
require 'github/markup'
require 'stringex'
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
  @snippets = Snippet.all
  erb :index, :locals => {
    :site_name  => settings.config['site_name'],
    :author     => settings.config['author_name'],
  }
end

get '/404' do
  erb :'404'
end

get '/new' do
  @snippet = Snippet.new
  erb :new, :locals => {
    :site_name => settings.config['site_name'],
    :snippet   => @snippet,
    :tags      => '',
  }
end

post '/new' do
  @snippet = Snippet.new
  @snippet.title = params[:title]
  @snippet.slug  = params[:title].to_url
  @tags          = params[:tags]

  @alerts = []
  @alerts << { type: :error, message: 'Fill in the title field!' } if params[:title].to_s.empty?
  @alerts << { type: :error, message: 'Fill in the content field!' } if params[:body].to_s.empty?
  unless params[:password] == settings.config['password'] and params[:password] == settings.config['password']
    @alerts << { type: :error, message: 'Wrong username or password!' }
  end

  unless @alerts.empty?
    @snippet.body  = params[:body]
    return erb :new, :locals => {
      :snippet   => @snippet,
      :tags      => @tags,
      :site_name => settings.config['site_name'],
    }
  end

  @snippet.body  = get_formatted_text params[:body]

  unless params[:tags].to_s.empty?
    tags = params[:tags].split(',')
    tags = [tags] unless tags.kind_of?(Array)
    tags.each_with_index do |tag, key|
      t = Tag.new(:tag => tag.strip)
      if t.save
        tags[key] = t
      else
        tags[key] = Tag.first(:tag => t.tag)
      end
    end
    @snippet.tags = tags
  end

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
  else
    session[:alerts] << { type: :success, message: "Snippet successfully deleted!" }
    snippet.destroy
  end
  redirect '/'
end

get '/:slug' do
  @snippet = Snippet.first(:slug => params[:slug])
  redirect '/404' if @snippet.nil?
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
