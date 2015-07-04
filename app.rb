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
  # クロール
  feed_url="http://b.hatena.ne.jp/search/text?q=slideshare&mode=rss"
  rss = RSS::Parser.parse(feed_url)
  
  entries = []

  rss.items.each do |item|

    puts title = item.title
    puts url = item.link
    puts description = item.description
    # puts item.hatena_bookmarkcount
  
    entry = Entry.new(title, url, description)
    puts entry.show
    puts ""

    entries.push(entry)

  end

  @entries = entries
  erb :crawl

end

get '/entries' do
  @entries = Entry.find_all
  erb :crawl
end