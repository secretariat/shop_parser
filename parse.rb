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


page = Nokogiri::HTML(open("http://www.6pm.com/mens-shoes~s?s=goliveRecentSalesStyle/desc/#!/men-sneakers-athletic-shoes/CK_XARC81wHAAQLiAgMBGAI.zso?s=goliveRecentSalesStyle/desc/"))
SearchResult = page.css("div#searchResults")
item_links = SearchResult.css("a")
item_links.each do |link|
	image = link.css("img.productImg")
	brandName = link.css("span.brandName").text
	productName = link.css("span.productName").text
	price = link.css("span.price-6pm").text
	discount = link.css("span.discount").text
	Shoes.create( :image => image.to_s, :brandname => brandName, :productname => productName, :price => price, :discount => discount)
	puts "#{image}\n#{brandName}\n#{productName}\n#{price}\n#{discount}\n"
	puts "-------------------------------"
end