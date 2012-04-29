require 'sinatra/reloader'
require 'sinatra'
require 'rubygems'
require 'data_mapper'
require 'yaml'
require 'github/markup'
require './models/snippet.rb'
require './models/tag.rb'
require './models/snippettag.rb'

configure do
  set :config, YAML.load_file('config.yml')
  DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/furry.db")
  DataMapper.finalize
  Snippet.auto_upgrade!
  Tag.auto_upgrade!
  SnippetTag.auto_upgrade!
end

get '/' do
  @snippets = Snippet.all
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
  }
end

post '/new' do
  @snippet = Snippet.new
  @snippet.title = params[:title]
  @snippet.body  = params[:body]

  @alerts = []
  @alerts << { type: :error, message: 'Fill in the title tag!' } if params[:title].to_s.empty?
  @alerts << { type: :error, message: 'Fill in the content tag!' } if params[:body].to_s.empty?
  erb :new, :locals => {
    :snippet   => @snippet,
    :site_name => settings.config['site_name'],
  } unless @alerts.empty?

  unless params[:tags].to_s.empty?
    tags = params[:tags].split(',')
    tags = [tags] unless tags.kind_of?(Array)
    tags.each_with_index do |tag, key|
      t = Tag.new(:tag => tag.strip!)
      if t.save
        tags[key] = t
      else
        tags[key] = Tag.first(:tag => tag)
      end
    end
  end

  @snippet.tags = tags
  @snippet.save
  redirect '/'
end

post '/get-formatted-text' do
  File.open('/tmp/furry.md', 'w')
  GitHub::Markup.render('/tmp/furry.md', params[:body])
end

get '/:slug' do
  filename = settings.config['snippets_folder'] + '/' + params[:slug] + '.md'
  snippet = {}
  snippet[:title] = IO.readlines(filename)[1]
  snippet[:tags]  = IO.readlines(filename)[2].split('-').trim
  snippet[:body] = GitHub::Markup.render(filename, File.read(filename))
  erb :show, :locals => {
    :snippet   => snippet,
    :author    => settings.config['author_name'],
    :site_name => settings.config['site_name'],
  }
end
