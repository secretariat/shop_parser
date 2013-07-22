# -*- encoding : utf-8 -*-

require 'yaml'
require 'nokogiri'
require 'open-uri'
require 'active_record'
require './lib/shoes.rb'
require './lib/funcs.rb'
require './lib/configer.rb'

#############################################################
SITE_URL = "http://6pm.com"
HOME_DIR = File.join( Dir.home, "ror/garderob4ik/public/images" )
# HOME_DIR = "/var/www/sites/garderob4ik/public/images"
#############################################################

class ShopParser

	attr_accessor :gconfig

	def initialize( global_config )
		@db_config = YAML::load(File.open('./config/database.yml'))
		ActiveRecord::Base.establish_connection( @db_config )
		@gconfig = global_config
		@cur_dep = nil
		@cur_category = nil
		@cur_gender = nil
	end

	def process_brands( brand_name )
		if Brand.exists?( :name => brand_name )
			@cur_brand = Brand.find_by_name( brand_name.downcase )
			@cur_brand.update_attributes( :name_shown => brand_name)
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
				puts full_link
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
				activity = gconfig.cat_by_gender["#{@cur_dep.dep_name_en}"]["#{@cur_gender.gender_name}"]
				cat = Category.create( :cat_name_en => cat_name, :cat_link => cat_link, :active => activity )
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
			puts "CURRENT PAGE: -->#{i}"
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
			ar = Array.new
			links.each do |link|
				ar << link.text.to_i
			end

			pages_num = ar.max

			link_template = links[0]['href']
			puts link_template
			# if pagin_block.css("span.last")[0]
			# 	pages_num = pagin_block.css("span.last")[0].text.gsub!("...","").strip.to_i
			# else
			# 	pages_num = 4
			# end
			break
		end

		return link_template, pages_num
	end

	def browse_categories
		categories = Category.where( :departments_id => @cur_dep.id, :active => true )
		categories.each do |c|
			@cur_category = c
			page = open_page( c.cat_link )
			return if page.blank?
			puts "CATEGORY: #{c.cat_name_en.upcase}"
			BrowsePagesFromCategory( page )
		end
	end

	def BrowseItemsFromPage( page_link )

		page = open_page( page_link )

		return if page.blank?

		search_result = page.css("div#searchResults")
		item_links = search_result.css("a")
		item_links.each do |link|
			brandName = link.css("span.brandName").text

			next if !process_brands( brandName )

			ilink = "#{SITE_URL}#{link['href']}"
			product_id = link['data-product-id']
			style_id = link['data-style-id']
			image_link = link.css("img.productImg")[0]['src']
			image_full_path = "#{HOME_DIR}/#{(image_link.split(/\//).last).split("-").first}.jpg"
			image_path = "#{(image_link.split(/\//).last).split("-").first}.jpg"

			productName = link.css("span.productName").text
			price_usd = link.css("span.price-6pm").text.gsub!("$","").to_f
			price_ua = (get_price( link.css("span.price-6pm").text.gsub!("$","").to_f )).to_i
			discount = $1 if link.css("span.discount").text =~ /([\d]+)%/
			puts msrp_ua = (price_ua/((100-discount.to_f)/100.00)).to_i

			h_item = {
									:image_path => image_path,
									:product_id => product_id.to_i,
									:style_id => style_id.to_i,
									:productname => productName,
									:price_usd => price_usd,
									:price_ua => price_ua,
									:discount => discount,
									:msrp_ua => msrp_ua
								}
			shoe = Shoes.new( h_item, ilink )
			shoe.check_item
			shoe.get_shoes_description
			@cur_brand.items << shoe.get_item
			@cur_category.items << shoe.get_item
			ImageDownload( image_link, image_full_path )
		end
	end

	def process_styles( link )
	end

end

conf = Configer.new
conf.process_config


parse = ShopParser.new( conf )
parse.process_departments

# db_config = YAML::load(File.open('./config/database.yml'))
# ActiveRecord::Base.establish_connection( db_config )

# i = Item.find(:all)
# i.each do |item|
# 	puts item.productname
# 	colors = item.colors
# 	colors.each do |c|
# 		puts "\t>>>>#{c.id}--#{c.color_name}"
# 	end
# end