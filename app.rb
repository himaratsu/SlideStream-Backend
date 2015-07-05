require 'sinatra'
require 'sinatra/reloader' if development?
require 'rss'
require 'uri'
require 'yaml'
require "nokogiri"
require "open-uri"
require "open_uri_redirections"

require_relative 'models/entry.rb'

ActiveRecord::Base.configurations = YAML.load_file('database.yml')
ActiveRecord::Base.establish_connection(ENV["DATABASE_URL"] || :development)


get '/' do
  'Hello'
end

get '/crawl' do
  slideshare_url="http://b.hatena.ne.jp/search/text?q=slideshare&mode=rss&sort=popular"
  crawl(slideshare_url, "slideshare")

  # speakerdeck_url="http://b.hatena.ne.jp/search/text?q=speakerdeck&mode=rss&sort=popular"
  # crawl(speakerdeck_url, "speakerdeck")

  redirect 'entries'
end

get '/entries' do
  @entries = Entry.all
  erb :crawl
end

get '/entries.json' do 
  content_type :json, :charset => 'utf-8'
  entries = Entry.all
  entries.to_json
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


def crawl(feed_url, sitename)
  rss = RSS::Parser.parse(feed_url)

  rss.items.each do |item|

    if Entry.exists?(:link => item.link)
      entry = Entry.find_by_link(item.link)
      puts entry

      if sitename == "slideshare" 
        scrape_slideshare(item.link, entry)
      end

      entry.save

      puts "exist record:[ " + item.link + " ]"
    else
      entry = Entry.new
      entry.title = item.title
      entry.link = item.link
      entry.description = item.description

      if sitename == "slideshare" 
        scrape_slideshare(item.link, entry)
      end

      # puts item.hatena_bookmarkcount
      entry.save

      puts "save new record: " + item.title
    end
  end
end

def scrape_slideshare(url, entry)
  charset = nil

  begin
    html = open(url, :allow_redirections => :all) do |f|
      charset = f.charset
      f.read
    end
  rescue OpenURI::HTTPError => ex
      puts "Handle missing video here"
      return "no_url"
  end 

  doc = Nokogiri::HTML.parse(html, nil, charset)
  
  doc.xpath('//div[@id="svPlayerId"]').each do |node|
    p "*********" 
    p doc.title  # タイトルを表示
    p total_slides = node.xpath('//span[@id="total-slides"]').text
    entry.total_count = total_slides.to_i

    p slide_first = doc.xpath('//div[@class="slide show"]')[0].xpath('img[@class="slide_image"]').attribute('data-normal').value
    entry.slide_base_image_url = slide_first
    p "*********"
  end
      
end





