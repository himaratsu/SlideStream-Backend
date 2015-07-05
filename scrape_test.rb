require 'open-uri'
require 'open_uri_redirections'
require 'nokogiri'

charset = nil

url = "http://www.slideshare.net/onoremiz/ui-11779313"

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

  p slide_first = doc.xpath('//div[@class="slide show"]')[0].xpath('img[@class="slide_image"]').attribute('data-normal').value
  p "*********"
end
    