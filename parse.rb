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


# page = Nokogiri::HTML(open("http://www.6pm.com/mens-shoes~s?s=goliveRecentSalesStyle/desc/#!/men-sneakers-athletic-shoes/CK_XARC81wHAAQLiAgMBGAI.zso?s=goliveRecentSalesStyle/desc/"))
# page = Nokogiri::HTML(open("http://www.6pm.com/womens-shoes~1gp?s=recentSalesStyle/desc#!/womens-sandals~yD?s=recentSalesStyle/desc/"))
# page = Nokogiri::HTML(open("http://www.6pm.com/women-sandals-page1/CK_XARC51wHAAQHiAgMBGAI.zso?p=1&s=goliveRecentSalesStyle/desc/"))
# SearchResult = page.css("div#searchResults")
# item_links = SearchResult.css("a")
# item_links.each do |link|
	# puts link
	# ilink = "http://6pm.com#{link['href']}"
	# GetItemDetails( ilink )
	# image = link.css("img.productImg")[0]['src']
	# puts brandName = link.css("span.brandName").text
	# productName = link.css("span.productName").text
	# price = link.css("span.price-6pm").text
	# discount = link.css("span.discount").text
	# Shoes.create( :ilink => ilink, :image => image.to_s, :brandname => brandName, :productname => productName, :price_orig => price, :discount => discount)
	# puts "#{image}\n#{brandName}\n#{productName}\n#{price}\n#{discount}\n"
	# puts "-------------------------------"
# end


def GetWomenShoesCategories()
	page = Nokogiri::HTML(open("http://www.6pm.com/shoes"))
	category_block = page.css("div.sideColumn")
	male_category_block = category_block.css("h5")
	# puts male_category_block.text
	category_links = category_block.css('a[class^="gae-click"]')
	category_links.each do |link|
		puts "#{link['href'] http://6pm.com#{link['href']}"
		break if link.text == "Men's"
	end
end

GetWomenShoesCategories()