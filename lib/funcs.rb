######################################################
CURRENCY = 8.15
######################################################


def get_gender_from_link( link )
	case link
		when /Men/ ; return "Men"
		when /Women/ ; return "Women"
		when /Boys/i ; return "Boys"
		when /Girls/i ; return "Girls"
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
	rescue
		puts "Image not found"
	end
end