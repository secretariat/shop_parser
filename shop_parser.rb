# -*- encoding : utf-8 -*-

require 'yaml'
require 'nokogiri'
require 'open-uri'
require 'active_record'
require './lib/funcs.rb'
require './lib/configer.rb'

#############################################################
SITE_URL = "http://6pm.com"
HOME_DIR = File.join( Dir.home, "ror/garderob4ik/public/images" )
# HOME_DIR = "/var/www/sites/garderob4ik/public/images"
#############################################################

class ShopParser

	def initialize( global_config )
		@db_config = YAML::load(File.open('./config/database.yml'))
		@gconfig = global_config
		ActiveRecord::Base.establish_connection( @db_config )
		@cur_dep = nil
		@cur_category = nil
		@cur_gender = nil
	end

	def process_brands( brand_name )
		if !Brand.exists?( :brand_name => brand_name )
			@cur_brand = Brand.create( :brand_name => brand_name )
		else
			@cur_brand = Brand.find_by_brand_name( brand_name )
		end
	end

	def process_departments
		deps = Departments.where( :active => true )
		deps.each do |d|
			@cur_dep = d
			case d.dep_name_en
				when "Shoes" ; process_shoes( d.dep_link )
				when "Clothing" ; puts "Clothing"
				when "Accessories" ; puts "Accessories"
				when "Bags" ; puts "Bags"
			end
		end
	end

	def process_shoes( dep_link )
		get_view_all_links( dep_link )
		browse_categories
	end

	def get_view_all_links( department_link )
		page = Nokogiri::HTML(open( department_link ))
		left_block = page.css("div#tcSideCol")
		view_all_links = left_block.css("a")
		view_all_links.each do |link|
			if link['class'] =~ /view-all last/
				full_link = "#{SITE_URL}#{link['href']}"
				gender = Gender.find_by_gender_name( get_gender_from_link( full_link ) )
				# puts gender.gender_name
				@cur_gender = gender
				get_gender_shoes_categories( full_link )
			end
		end
	end

	def get_gender_shoes_categories( gender_cat_link )
		page = Nokogiri::HTML( open( gender_cat_link ) )
		category_block = page.css("div#FCTzc2Select")
		male_category_links = category_block.css("a")
		male_category_links.each do |link|
			cat_name = link.text.strip
			cat_name = cat_name.split("(")[0].chomp
			cat_link = "#{SITE_URL}#{link['href']}"
			if !Category.exists?( :cat_link => cat_link )
				cat = Category.create( :cat_name_en => cat_name, :cat_link => cat_link)
				@cur_dep.categories << cat
				@cur_gender.categories << cat
			end
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
			break
		end
	end

	def pagination( page )
		pagin_block = page.css("div.pagination")
		link_template = ""
		pages_num = 0
		pagin_block.each do |pag|
			links = pag.css("a")
			link_template = links[0]['href']
			puts link_template
			if pagin_block.css("span.last")[0]
				pages_num = pagin_block.css("span.last")[0].text.gsub!("...","").strip.to_i
			else
				pages_num = 4
			end
			break
		end

		return link_template, pages_num
	end

	def browse_categories
		categories = Category.where( :departments_id => @cur_dep.id )
		categories.each do |c|
			@cur_category = c
			page = Nokogiri::HTML(open(c.cat_link))
			puts "CATEGORY: #{c.cat_name_en.upcase}"
			# sleep(1)
			BrowsePagesFromCategory( page )
		end
	end

	def BrowseItemsFromPage( page_link )
		begin
			page = Nokogiri::HTML(open( page_link ))
		rescue
			puts "PAGE NOT FOUND"
			sleep(10)
			return
		end
		search_result = page.css("div#searchResults")
		item_links = search_result.css("a")
		item_links.each do |link|
			ilink = "#{SITE_URL}#{link['href']}"
			product_id = link['data-product-id']
			style_id = link['data-style-id']
			# GetItemDetails( ilink )
			image_link = link.css("img.productImg")[0]['src']
			image_full_path = "#{HOME_DIR}/#{(image_link.split(/\//).last).split("-").first}.jpg"
			image_path = "#{(image_link.split(/\//).last).split("-").first}.jpg"
			# ImageDownload( image_link, image_full_path )
			brandName = link.css("span.brandName").text
			process_brands( brandName )
			productName = link.css("span.productName").text
			price_usd = link.css("span.price-6pm").text.gsub!("$","").to_f
			price_ua = (get_price( link.css("span.price-6pm").text.gsub!("$","").to_f )).to_i
			discount = link.css("span.discount").text
			if( !Item.exists?( :product_id => product_id.to_i, :style_id => style_id.to_i ) )
				item = Item.new( :image_path => image_path,
											:product_id => product_id.to_i,
											:style_id => style_id.to_i,
											:productname => productName,
											:price_usd => price_usd,
											:price_ua => price_ua,
											:discount => discount )
				GetItemDetails( item, ilink )
				@cur_category.items << item
				@cur_brand.items << item
				puts "#{product_id}\n#{style_id}\n#{image_path}\n#{brandName}\n#{productName}\n#{price_usd}\n#{price_ua}"
				ImageDownload( image_link, image_full_path )
				# GetItemDetails( item, ilink )
				# {discount}\n"
			end
			puts "-------------------------------"
		end
	end

	def GetItemDetails( item, item_url )
		puts item_url
		begin
			page = Nokogiri::HTML(open( item_url ))
		rescue Exception => e
			puts ">>>>>>>>>>>>ERROR: #{e.message}"
			return
		end
		puts sku = page.css("span#sku").text.split("#")[1].to_i
		main_image_div = page.css("div#detailImage")
		# puts main_image_path = main_image_div.css("img")[0]['src']
		thumbnails_block = page.css("div#productImages")
		# image_links_block = thumbnails_block.css('a[id^="frontrow-"]').text
		image_links_block = thumbnails_block.css('img')
		desc = Description.new( :sku => sku.to_i )
		item.description = desc
		image_links_block.each do |link|
			if link['src'] =~ /MULTIVIEW_THUMBNAILS/
				puts thumb_image_name = "#{link['src'].split(/\//).last.split(/-/)[0..1].join("-")}-thumb.jpg"
				puts large_image_name = "#{link['src'].split(/\//).last.split(/-/)[0..1].join("-")}.jpg"
				thumb_image_full_path = "#{HOME_DIR}/descriptions/#{thumb_image_name}"
				large_image_full_path = "#{HOME_DIR}/descriptions/#{large_image_name}"
				large_image_download_link = link['src'].gsub("_THUMBNAILS","")
				desc.images << Image.new( :thumb_path => thumb_image_name, :image_path => large_image_name )
				ImageDownload( link['src'], thumb_image_full_path )
				ImageDownload( large_image_download_link, large_image_full_path )
			end
		end
	end

end

conf = Configer.new
conf.process_config

parse = ShopParser.new( conf )
parse.process_departments
# parse.get_subdepartments
