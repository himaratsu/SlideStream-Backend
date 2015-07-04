require 'sinatra'
require 'sinatra/reloader' if development?
require 'rss'
require 'uri'
require 'yaml'
require_relative 'models/entry.rb'

ActiveRecord::Base.configurations = YAML.load_file('database.yml')
ActiveRecord::Base.establish_connection(ENV["DATABASE_URL"] || :development)


get '/' do
  'Hello'
end

get '/crawl' do
  slideshare_url="http://b.hatena.ne.jp/search/text?q=slideshare&mode=rss&sort=popular"
  crawl(slideshare_url)

  speakerdeck_url="http://b.hatena.ne.jp/search/text?q=speakerdeck&mode=rss&sort=popular"
  crawl(speakerdeck_url)

  redirect 'entries'
end

get '/entries' do
  @entries = Entry.all
  erb :crawl
end

get '/new' do
  erb :new_entry
end

post '/new' do
  entry = Entry.new
  entry.title = params[:title]
  entry.link = params[:link]
  entry.description = params[:description]
  entry.save

  redirect '/entries'
end


def crawl(feed_url)
  rss = RSS::Parser.parse(feed_url)

  rss.items.each do |item|
    if Entry.exists?(:link => item.link)
      puts "exist record:[ " + link + " ]"
    else
      entry = Entry.new
      entry.title = item.title
      entry.link = item.link
      entry.description = item.description
      # puts item.hatena_bookmarkcount
      entry.save

      puts "save new record: " + item.title
    end
  end
end





