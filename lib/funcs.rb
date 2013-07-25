# -*- encoding : utf-8 -*-

######################################################
CURRENCY = 8.15
######################################################


def get_gender_from_link( link )
	case link
		when /\/mens/i ; return "Men"
		when /womens/i ; return "Women"
		when /boys/i ; return "Boys"
		when /girls/i ; return "Girls"
	end
end

def get_price( price_usd )
	price = (price_usd*CURRENCY)+200
end

def ImageDownload( image_url, image_path )
	begin
		open( image_url ) do |f|
	  	File.open( image_path ,"wb" ) do |file|
		  	file.puts f.read
			end
		end
	rescue Exception => e
		puts "ERROR while downloading image: #{e.message}"
	end
end

def open_page( page_link )
	begin
		page = Nokogiri::HTML(open( page_link ))
	rescue Exception => e
		puts "ERROR: #{e.message}"
	end
end

