require 'open-uri'
require 'open_uri_redirections'
require 'nokogiri'
require 'watir'
require "watir-webdriver"
require 'rest-client'

charset = nil

# url = "https://speakerdeck.com/ninjanails/death-to-icon-fonts"
url = "https://speakerdeck.com/ken_c_lo/zurui-design"

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

p slide_first_url = doc.xpath('//meta[@property="og:image"]').attribute('content').text.sub("_0.", "_{#No}.")
# https://speakerd.s3.amazonaws.com/presentations/fcfca49087d04571a050ba2e9e663f36/slide_0.jpg

p slide_hash = slide_first_url.split('/')[4]

doc = RestClient.get('http://speakerdeck.com/player/' + slide_hash)
parsed_doc = Nokogiri::HTML(doc) 
slide_count_nav = parsed_doc.xpath('//div[@class="previews"]').children.children.text
p slide_count_nav.split(" ").last

