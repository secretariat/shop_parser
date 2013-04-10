# -*- encoding : utf-8 -*-

require 'nokogiri'
require 'open-uri'
require 'active_record'
require 'logger'
require 'yaml'


#########---Getting database connection---############
db_config = YAML::load(File.open('./config/database.yml'))
ActiveRecord::Base.establish_connection( db_config )
ActiveRecord::Base.logger = Logger.new(File.open('./log/database.log', 'a'))
######################################################

class Shoes < ActiveRecord::Base
end

class Wcategory < ActiveRecord::Base
end

def ImageDownload( image_url )
	open(item_image_main) do |f|
  	File.open("images/test.jpg","wb") do |file|
	  	file.puts f.read
		end
	end
end

def GetItemDetails( item_url )
	# puts "ITEM_URL: #{item_url}"
	page = Nokogiri::HTML(open( item_url ))
	header_block =  page.css("h1").text
	puts header_block

	item_image_main = page.css("img#detailImage")[0]['src']

	item_images = page.css("div#productImages")
	item_list = page.css("ul")
	puts item_list
	# images = item_list.css('li')
	# images.each do |li|
	# 	puts li.css('a')[0].text
	# end

	# puts header_block.css("a").text
	# puts header_block.css("span.sku").text
end

def BrowseItemsFromCategory( page )
	search_result = page.css("div#searchResults")
	item_links = search_result.css("a")
	item_links.each do |link|
		puts link
		ilink = "http://6pm.com#{link['href']}"
		GetItemDetails( ilink )
		image = link.css("img.productImg")[0]['src']
		puts brandName = link.css("span.brandName").text
		productName = link.css("span.productName").text
		price = link.css("span.price-6pm").text
		discount = link.css("span.discount").text
		Shoes.create( :ilink => ilink, :image => image.to_s, :brandname => brandName, :productname => productName, :price_orig => price, :discount => discount)
		puts "#{image}\n#{brandName}\n#{productName}\n#{price}\n#{discount}\n"
		puts "-------------------------------"
	end
end

def GetWomenShoesCategories()
	page = Nokogiri::HTML(open("http://www.6pm.com/womens-shoes~b?s=goliveRecentSalesStyle/desc/"))
	category_block = page.css("div#FCTzc2Select")
	male_category_links = category_block.css("a")
	male_category_links.each do |link|
		cat_name = link.text.strip
		cat_name = cat_name.split("(")[0].chomp
		puts cat_name
		cat_link = "http://6pm.com#{link['href']}"
		Wcategory.create( :cat_name_en => cat_name, :cat_link => cat_link)
	end
end

def BrowseCategories( model )
	links = model.find(:all)
	links.each do |l|
		page = Nokogiri::HTML(open(l.cat_link))
		puts "CATEGORY: #{l.cat_name_en}.upcase:"
		BrowseItemsFromCategory( page )
	end
end


GetWomenShoesCategories()
BrowseCategories( Wcategory )