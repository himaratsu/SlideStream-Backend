require 'sinatra'
require 'sinatra/reloader' if development?
require 'rss'
require 'uri'
require 'yaml'
require "nokogiri"
require "open-uri"
require "open_uri_redirections"
require 'rest-client'

require_relative 'models/entry.rb'

ActiveRecord::Base.configurations = YAML.load_file('database.yml')
ActiveRecord::Base.establish_connection(ENV["DATABASE_URL"] || :development)


get '/' do
  'Hello'
  redirect 'entries'
end

get '/crawl' do

  if params.empty? || params.include?(:mode)
    crawl_today_entry
  elsif params[:mode] == "today"
    crawl_today_entry
  elsif params[:mode] == "this_week"
    crawl_this_week_entry
  elsif params[:mode] == "this_month"
    crawl_this_month_entry
  else
    crawl_today_entry
  end

  redirect 'entries'
end

get '/crawl_with_date' do

  if params.empty?
    '[Error] Usage: crawl_with_date?date=2015-07-01'
  elsif params.include?("date")
    crawl_with_date(params[:date])
    redirect 'entries'
  elsif params.include?("start_date") && params.include?("end_date")
    crawl_with_date(params[:start_date], params[:end_date])
    redirect 'entries'
  else 
    'Something Wrong'
  end
end

get '/crawl_hotentry' do
  crawl_all_hotentry
  redirect 'entries'
end

get '/entries' do

  if params.empty? || params.include?(:mode)
    entries = Entry.all
  elsif params[:mode] == "today"
    from = Time.now.at_beginning_of_day
    to = from + 1.day
    entries = Entry.where(postdate: from...to)
  elsif params[:mode] == "this_week"
    from = Time.now.at_beginning_of_week
    to   = from + 1.week
    entries = Entry.where(postdate: from...to)
  elsif params[:mode] == "this_month"
    from = Time.now.at_beginning_of_month
    to   = from + 1.month
    entries = Entry.where(postdate: from...to)
  elsif params[:mode] == "all"
    entries = Entry.all
  else
    entries = Entry.all
  end

  @entries = entries
  erb :crawl
end

get '/entries.json' do 
  content_type :json, :charset => 'utf-8'

  if params.empty? || params.include?(:mode)
    entries = Entry.all
  elsif params[:mode] == "today"
    from = Time.now.at_beginning_of_day
    to = from + 1.day
    entries = Entry.where(postdate: from...to)
  elsif params[:mode] == "this_week"
    from = Time.now.at_beginning_of_week
    to   = from + 1.week
    entries = Entry.where(postdate: from...to)
  elsif params[:mode] == "this_month"
    from = Time.now.at_beginning_of_month
    to   = from + 1.month
    entries = Entry.where(postdate: from...to)
  elsif params[:mode] == "all"
    entries = Entry.all
  else
    entries = Entry.all
  end

  if params.empty? || params.include?(:sort)
    entries = entries.order("hatebu_count DESC")
  elsif params[:sort] == "latest"
    entries = entries.order("postdate")
  end

  entries.to_json
end

get '/entries/detail' do

  if params.include?(:url)
    '[Usage] /entries/detail?url=http://www.slideshare.net/masatonoguchi169/sprockets-49965435'
    return
  end

  url = params[:url]
  @entry = Entry.find_by_link(url)
  erb :detail
end

get '/refresh' do

  entries = Entry.all
  entries.each do |entry|
    url = "http://api.b.st-hatena.com/entry.count?url=#{entry.link}"

    charset = nil

    begin
      value = open(url) do |f|
        charset = f.charset
        f.read
      end
    rescue OpenURI::HTTPError => ex
        puts "Handle missing video here"
        return "no_url"
    end 

    p entry.hatebu_count = value
    entry.save
  end

  redirect 'entries'
end


def crawl(feed_url, sitename)

  xml_doc = Nokogiri::XML.parse(open(feed_url))

  item_nodes = xml_doc.css("//item")

  item_nodes.each do |item|

    title = item.css('title').text
    link = item.css('link').text
    description = item.css('description').text
    dc_date = item.css('dc|date').text
    dc_subject = item.css('dc|subject').text
    hatena_bookmarkcount = item.css('hatena|bookmarkcount').text

    if sitename == "slideshare" && !link.include?("www.slideshare.net")
      next
    elsif sitename == "Speaker Deck" && !link.include?("speakerdeck.com")
      next
    end

    if Entry.exists?(:link => link)
      entry = Entry.find_by_link(link)

      if sitename == "slideshare" 
        scrape_slideshare(link, entry)
      elsif sitename == "Speaker Deck" 
        scrape_speakerdeck(link, entry)
      end

      entry.hatebu_count = hatena_bookmarkcount
      entry.save

      puts "exist record:[ " + title + " ]"
    else
      entry = Entry.new
      entry.title = title
      entry.link = link
      entry.description = description
      entry.postdate = dc_date


      entry.category = dc_subject
      entry.hatebu_count = hatena_bookmarkcount
      entry.sitename = sitename

      if sitename == "slideshare" 
        scrape_slideshare(link, entry)
      elsif sitename == "Speaker Deck" 
        scrape_speakerdeck(link, entry)
      end

      entry.save

      puts "save new record: " + title
    end
  end
end

def crawl_slideshare_and_speakerdeck
  
end

def crawl_all_hotentry
  slideshare_url="http://b.hatena.ne.jp/search/text?q=www.slideshare.net&mode=rss&sort=popular"
  crawl(slideshare_url, "slideshare")

  speakerdeck_url = "http://b.hatena.ne.jp/search/text?q=speakerdeck.com&sort=popular&mode=rss"
  crawl(speakerdeck_url, "Speaker Deck")
end

def crawl_today_entry
  today = Date.today
  todayStr = today.strftime("%Y-%m-%d")
  crawl_with_date(todayStr)
end

def crawl_this_week_entry
  p from = Time.now.at_beginning_of_week
  p to   = from + 1.week
  crawl_with_date(from.strftime("%Y-%m-%d"), to.strftime("%Y-%m-%d"))
end

def crawl_this_month_entry
  p from = Time.now.at_beginning_of_month
  p to   = from + 1.month
  crawl_with_date(from.strftime("%Y-%m-%d"), to.strftime("%Y-%m-%d"))
end

def crawl_with_date(startDateStr, endDateStr=nil)

  if endDateStr == nil
    endDateStr = startDateStr
  end

  slideshare_feed_url = "http://b.hatena.ne.jp/search/text?date_begin="+startDateStr+"&date_end="+endDateStr+"&q=www.slideshare.net&sort=popular&users=&mode=rss"
  crawl(slideshare_feed_url, "slideshare")

  speakerdeck_feed_url = "http://b.hatena.ne.jp/search/text?date_begin="+startDateStr+"&date_end="+endDateStr+"&q=speakerdeck.com&sort=popular&users=&mode=rss"
  crawl(speakerdeck_feed_url, "Speaker Deck")
end

def scrape_slideshare(url, entry)
  charset = nil

  begin
    html = open(url, :allow_redirections => :all) do |f|
      charset = f.charset
      f.read
    end
  rescue OpenURI::HTTPError => ex
      return "no_url"
  end 

  doc = Nokogiri::HTML.parse(html, nil, charset)
  
  doc.xpath('//div[@id="svPlayerId"]').each do |node|
    p total_slides = node.xpath('//span[@id="total-slides"]').text
    entry.total_count = total_slides.to_i

    p slide_first = doc.xpath('//section[@class="slide show"]')[0].xpath('img[@class="slide_image"]').attribute('data-normal').value
    entry.slide_base_image_url = slide_first.sub("-1-", "-#No-")
    p "------------"
  end 
end

def scrape_speakerdeck(url, entry)

  p url

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

  p slide_first_url = doc.xpath('//meta[@property="og:image"]').attribute('content').text.sub("_0.", "_#No.")
  entry.slide_base_image_url = slide_first_url

  p slide_hash = slide_first_url.split('/')[4]

  doc = RestClient.get('http://speakerdeck.com/player/' + slide_hash)
  parsed_doc = Nokogiri::HTML(doc) 
  slide_count_nav = parsed_doc.xpath('//div[@class="previews"]').children.children.text
  p total_slides = slide_count_nav.split(" ").last
  entry.total_count = total_slides
end





