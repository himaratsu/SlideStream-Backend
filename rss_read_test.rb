require 'rss'

today = Date.today
p todayStr = today.strftime("%Y-%m-%d")

feed_url = "http://b.hatena.ne.jp/search/text?date_begin="+todayStr+"&date_end="+todayStr+"&q=www.slideshare.net&sort=popular&users=&mode=rss"

# feed_url = "http://b.hatena.ne.jp/search/text?q=www.slideshare.net&mode=rss&sort=popular"
rss = RSS::Parser.parse(feed_url, false, false)

rss.items.each do |item|

  p item.title
  p item.link
  p item.description
  p item.dc_date
  p item.dc_subject

  p "---"
end