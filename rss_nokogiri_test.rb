require 'open-uri'
require 'nokogiri'

feed_url = "http://b.hatena.ne.jp/search/text?q=www.slideshare.net&mode=rss&sort=popular"

xml_doc = Nokogiri::XML.parse(open(feed_url))

item_nodes = xml_doc.css("//item")

item_nodes.each do |item|
  p item.css('title').text
  p item.css('link').text
  p item.css('description').text
  p item.css('dc|date').text
  p item.css('dc|subject').text
  p item.css('hatena|bookmarkcount').text
  p "-------------"
end
