require 'sinatra/reloader'
require 'sinatra'
require 'rubygems'
require 'data_mapper'
require 'yaml'
require 'github/markup'
require './models/snippet.rb'
require './models/tag.rb'

configure do
  set :config, YAML.load_file('config.yml')
  DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/furry.db")
  DataMapper.finalize
  Snippet.auto_upgrade!
  Tag.auto_upgrade!
end

get '/' do
  @snippets = Snippet.all
  erb :index, :locals => {
    :site_name  => settings.config['site_name'],
    :author     => settings.config['author_name'],
  }
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
