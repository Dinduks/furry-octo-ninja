require 'sinatra/reloader'
require 'sinatra'
require 'yaml'
require 'github/markup'

configure do
  set :config, YAML.load_file('config.yml')
end

get '/' do
  snippets = []
  Dir.foreach('snippets') do |s| 
    next if s == '.' or s == '..'
    filename = settings.config['snippets_folder'] + '/' + s
    snippet = {}
    snippet[:slug]  = s.slice(0..-4)
    snippet[:title] = IO.readlines(filename)[1]
    snippet[:tags]  = IO.readlines(filename)[2].split('-').each { |t| t.strip! }
    snippets << snippet
  end
  erb :index, :locals => {
    :site_name  => settings.config['site_name'],
    :author     => settings.config['author_name'],
    :snippets   => snippets,
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
