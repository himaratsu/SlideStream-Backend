require 'open-uri'
require 'open_uri_redirections'
require 'nokogiri'
require 'watir'
require "watir-webdriver"
require 'rest-client'

charset = nil

url = "https://speakerdeck.com/ninjanails/death-to-icon-fonts"
# url = "https://speakerdeck.com/ken_c_lo/zurui-design"
# url = "http://sssslide.com/speakerdeck.com/pyama86/pepaboniokeruopenstackhacks"

begin
  html = open(url, :allow_redirections => :all) do |f|
    charset = f.charset
    f.read
  end
rescue OpenURI::HTTPError => ex
    puts "Handle missing video here"
    return "no_url"
end 

# browser = Watir::Browser.new
# browser.goto url

# p browser.title
# p browser.url

# browser.wait


# doc = Nokogiri::HTML.parse(browser.html)

# p doc
doc = Nokogiri::HTML.parse(html, nil, charset)

# p "*********" 
p doc.xpath('//meta[@property="og:image"]').attribute('content').text
# p doc.title  # タイトルを表示
# p total_slides = doc.xpath('//div[@class="selections"]')

# p slide_first = doc.xpath('//div[@id="player-content-wrapper"]')
# p slide_title = doc.xpath('//h1').text

# p total_slides = doc.xpath('//div[@id="js__slide"]').attribute('data-total-slides').value

# p "*********"


doc = RestClient.get('http://speakerdeck.com/player/fcfca49087d04571a050ba2e9e663f36?')
parsed_doc = Nokogiri::HTML(doc) 
p parsed_doc

p parsed_doc.xpath('//div[@class="previews"]').children.children.text
# parsed_doc.css('#yourSelectorHere') # or parsed_doc.xpath('...')
