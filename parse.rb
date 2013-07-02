# -*- encoding : utf-8 -*-

require 'nokogiri'
require 'open-uri'
require 'active_record'
require 'logger'
require 'yaml'

SITE_URL = "http://6pm.com"
HOME_DIR = Dir.home
$sum = 0
CURRENCY = 8.15

#########---Getting database connection---############
db_config = YAML::load(File.open('./config/database.yml'))
ActiveRecord::Base.establish_connection( db_config )
ActiveRecord::Base.logger = Logger.new(File.open('./log/database.log', 'a'))
######################################################

class Shoes < ActiveRecord::Base
end

class Wcategory < ActiveRecord::Base
end


def get_price( price_usd )
	price = (price_usd*CURRENCY)+200
end

def ImageDownload( image_url, image_path )
	open( image_url ) do |f|
  	File.open( image_path ,"wb" ) do |file|
	  	file.puts f.read
		end
	end
end

def GetItemDetails( item_url )
	# page = Nokogiri::HTML(open( item_url ))
	# header_block =  page.css("h1").text
	# item_image_main = page.css("img#detailImage")[0]['src']
	# item_images = page.css("div#productImages")
	# item_list = page.css("ul")
	# puts item_list
	# images = item_list.css('li')
	# images.each do |li|
	# 	puts li.css('a')[0].text
	# end

	# puts header_block.css("a").text
	# puts header_block.css("span.sku").text
end

def BrowseItemsFromPage( page_link )
	page = Nokogiri::HTML(open( page_link ))
	search_result = page.css("div#searchResults")
	item_links = search_result.css("a")
	item_links.each do |link|
		ilink = "#{SITE_URL}#{link['href']}"
		# GetItemDetails( ilink )
		image_link = link.css("img.productImg")[0]['src']
		image_path = "#{HOME_DIR}/garderob4ik/#{(image_link.split(/\//).last).split("-").first}.jpg"
		ImageDownload( image_link, image_path )
		brandName = link.css("span.brandName").text
		productName = link.css("span.productName").text
		price_usd = link.css("span.price-6pm").text.gsub!("$","").to_f
		price_ua = (get_price( link.css("span.price-6pm").text.gsub!("$","").to_f )).to_i
		discount = link.css("span.discount").text
		Shoes.create( :image_path => image_path,
									:brandname => brandName,
									:productname => productName,
									:price_usd => price_usd,
									:price_ua => price_ua,
									:discount => discount )
		puts "#{image_path}\n#{brandName}\n#{productName}\n#{price_usd}\n#{price_ua}"
		# {discount}\n"
		puts "-------------------------------"
		$sum += 1
	end
end


def BrowsePagesFromCategory( page )

	link_template, pages_num = pagination( page )
 	cur_page_link = link_template.gsub!(/page[0-9]/, "pageX")
 	cur_page_link_tmp = link_template.gsub!(/p=[0-9]/, "p=Z")
	1.upto(pages_num) do |i|
		page_link = cur_page_link_tmp.gsub(/pageX/, "page#{i}")
		page_link = page_link.gsub(/p=Z/, "p=#{i-1}")
		ready_link = "#{SITE_URL}#{page_link}"
		BrowseItemsFromPage( ready_link )
	end
end

def GetWomenShoesCategories()
	page = Nokogiri::HTML(open("http://www.6pm.com/womens-shoes~b?s=goliveRecentSalesStyle/desc/"))
	category_block = page.css("div#FCTzc2Select")
	male_category_links = category_block.css("a")
	male_category_links.each do |link|
		cat_name = link.text.strip
		cat_name = cat_name.split("(")[0].chomp
		cat_link = "#{SITE_URL}#{link['href']}"
		Wcategory.create( :cat_name_en => cat_name, :cat_link => cat_link)
	end
end

def pagination( page )
	pagin_block = page.css("div.pagination")
	link_template = ""
	pages_num = 0
	pagin_block.each do |pag|
		links = pag.css("a")
		link_template = links[0]['href']
		pages_num = pagin_block.css("span.last")[0].text.gsub!("...","").strip.to_i
		break
	end

	return link_template, pages_num
end

def BrowseCategories( model )
	links = model.find(:all)
	links.each do |l|
		page = Nokogiri::HTML(open(l.cat_link))
		puts "CATEGORY: #{l.cat_name_en.upcase}"
		BrowsePagesFromCategory( page )
	end
end


GetWomenShoesCategories()
BrowseCategories( Wcategory )
