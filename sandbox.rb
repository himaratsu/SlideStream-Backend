require 'uri'
require 'open-uri'

url = "http://api.b.st-hatena.com/entry.count?url=http://www.slideshare.net/onoremiz/ui-11779313"

# charset = nil

# begin
#   value = open(url) do |f|
#     charset = f.charset
#     f.read
#   end
# rescue OpenURI::HTTPError => ex
#     puts "Handle missing video here"
#     return "no_url"
# end 

# p value

# Hatena
open(url) do |f|
  puts "Hatena=" + f.read
end
