require 'rss'

feed_url = "http://b.hatena.ne.jp/search/text?q=www.slideshare.net&mode=rss&sort=popular"
rss = RSS::Parser.parse(feed_url, false, false)

rss.items.each do |item|

  p item

  p item.title
  p item.link
  p item.description

  p item.bookmarkcount
  p item.dc_date
  p item.dc_subject

  p ""
end