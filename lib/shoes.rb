require 'open-uri'

class Shoes
	def process_shoes_page
		
	end

	def open_page( link )
		begin
			page = Nokogiri::HTML(open( page_link ))
		rescue Exception => e
			
		end
	end
end