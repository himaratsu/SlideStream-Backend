require 'open-uri'
require 'open_uri_redirections'
require 'nokogiri'

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

doc = Nokogiri::HTML.parse(html, nil, charset)

# p "*********" 
p doc.xpath('//meta[@property="og:image"]').attribute('content').text
p doc.xpath()
# p doc.title  # タイトルを表示
# p total_slides = doc.xpath('//div[@class="selections"]')

# p slide_first = doc.xpath('//img[@id="slide_image"]')


# p total_slides = doc.xpath('//div[@id="js__slide"]').attribute('data-total-slides').value

# p "*********"