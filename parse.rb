# -*- encoding : utf-8 -*-

require 'nokogiri'
require 'open-uri'
require 'active_record'
require 'logger'
require 'yaml'

SITE_URL = "http://6pm.com"
HOME_DIR = File.join( Dir.home, "ror/garderob4ik/app/assets/images" )
# HOME_DIR = "/var/www/sites/garderob4ik/app/assets/images"
$sum = 0
CURRENCY = 8.15

#########---Getting database connection---############
db_config = YAML::load(File.open('./config/database.yml'))
ActiveRecord::Base.establish_connection( db_config )
ActiveRecord::Base.logger = Logger.new(File.open('./log/database.log', 'a'))
######################################################

class Departments < ActiveRecord::Base
end

class Subdepartments < ActiveRecord::Base
end

class Shoes < ActiveRecord::Base
	belongs_to :wcategory
	belongs_to :wcategory
end

class Wcategory < ActiveRecord::Base
	has_many :shoess
end

def departs_to_db
	
end


def get_departments
	page = Nokogiri::HTML(open(SITE_URL))
	nav_block = page.css("div#nav").css("ul").last
	links = nav_block.css("a")
	links.each do |l|
		next if l.text =~ /Women/ || l.text =~ /Men/ || l.text =~ /Kids/ || l.text =~ /brands/u
		dep_url = "#{SITE_URL}#{l['href']}"
		Departments.create(:dep_name_en => l.text, :dep_link => dep_url )
		get_subdepartments( dep_url )
	end
end

def get_subdepartments( department_link )
	puts department_link
	page = Nokogiri::HTML(open( department_link ))
	left_block = page.css("div#tcSideCol")
	view_all_links = left_block.css("a")
	view_all_links.each do |link|
		puts link['href'] if link['class'] =~ /view-all last/
	end
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

def BrowseItemsFromPage( page_link, cat_id )
	page = Nokogiri::HTML(open( page_link ))
	search_result = page.css("div#searchResults")
	item_links = search_result.css("a")
	item_links.each do |link|
		ilink = "#{SITE_URL}#{link['href']}"
		# GetItemDetails( ilink )
		image_link = link.css("img.productImg")[0]['src']
		image_full_path = "#{HOME_DIR}/#{(image_link.split(/\//).last).split("-").first}.jpg"
		image_path = "#{(image_link.split(/\//).last).split("-").first}.jpg"
		ImageDownload( image_link, image_full_path )
		brandName = link.css("span.brandName").text
		productName = link.css("span.productName").text
		price_usd = link.css("span.price-6pm").text.gsub!("$","").to_f
		price_ua = (get_price( link.css("span.price-6pm").text.gsub!("$","").to_f )).to_i
		discount = link.css("span.discount").text
		wc = Wcategory.find( cat_id )
		sh = Shoes.create( :image_path => image_path,
									:brandname => brandName,
									:productname => productName,
									:price_usd => price_usd,
									:price_ua => price_ua,
									:discount => discount )
		wc.shoess << sh
		puts "#{image_path}\n#{brandName}\n#{productName}\n#{price_usd}\n#{price_ua}"
		# {discount}\n"
		puts "-------------------------------"
		$sum += 1
	end
end


def BrowsePagesFromCategory( page, cat_id )

	link_template, pages_num = pagination( page )
 	cur_page_link = link_template.gsub!(/page[0-9]/, "pageX")
 	cur_page_link_tmp = link_template.gsub!(/p=[0-9]/, "p=Z")
	1.upto(pages_num) do |i|
		page_link = cur_page_link_tmp.gsub(/pageX/, "page#{i}")
		page_link = page_link.gsub(/p=Z/, "p=#{i-1}")
		ready_link = "#{SITE_URL}#{page_link}"
		BrowseItemsFromPage( ready_link, cat_id )
		break
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
		sleep(1)
		BrowsePagesFromCategory( page, l.id )
		puts $sum
	end
end


# GetWomenShoesCategories()
# BrowseCategories( Wcategory )

# get_departments
