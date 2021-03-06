# -*- encoding : utf-8 -*-
PATH = File.expand_path(File.dirname(__FILE__))
require "#{PATH}/header.rb"

class ShopParser

	include Common

	attr_accessor :gconfig

	def initialize( global_config )
		@gconfig = global_config
		@cur_dep = nil
		@cur_category = nil
		@cur_gender = nil
	end

	def process_brands( brand_name )
		if Brand.exists?( :name => brand_name )
			cur_brand = Brand.find_by_name( brand_name.downcase )
			cur_brand.update_attributes( :name_shown => brand_name)
			return cur_brand
		else
			return false
		end
	end

	def process_departments
		deps = Departments.where( :active => true )
		deps.each do |d|
			@cur_dep = d
			case d.name_us
				when "Shoes" ; process_shoes( d.link )
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
		was_parsed = 0
		view_all_links.each do |link|
			if link['class'] =~ /view-all last/
				full_link = "#{SITE_URL}#{link['href']}"
				gender = Gender.find_by_gender_name( get_gender_from_link( full_link ) )
				puts full_link
				get_style_and_material_links( full_link ) if was_parsed == 0
				was_parsed = 1
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
				activity = gconfig.cat_by_gender["#{@cur_dep.name_us}"]["#{@cur_gender.gender_name}"]
				cat = Category.create( :name_us => cat_name, :cat_link => cat_link, :active => activity )
				@cur_dep.categories << cat
				@cur_gender.categories << cat
			end
		end
	end

	def BrowsePagesFromCategory( page )
		link_template, pages_num = pagination( page )
	 	cur_page_link = link_template.gsub!(/page[0-9]/, "pageX")
	 	cur_page_link_tmp = link_template.gsub!(/p=[0-9]/, "p=Z")
	 	thread_pool = FutureProof::ThreadPool.new(5)
		1.upto(pages_num) do |i|
			# puts "CURRENT PAGE: -->#{i}"
			page_link = cur_page_link_tmp.gsub(/pageX/, "page#{i}")
			page_link = page_link.gsub(/p=Z/, "p=#{i-1}")
			ready_link = "#{SITE_URL}#{page_link}"
			thread_pool.submit ready_link, i do |link,i|
				BrowseItemsFromPage( link, i )
				# BrowseItemsFromPage( ready_link, i )
  		end
		end

		thread_pool.perform
		thread_pool.values

	end

	def browse_categories
		categories = Category.where( :departments_id => @cur_dep.id, :active => true )
		Log.info( "active categories for parsing: #{categories.size}" )
		categories.each do |c|
			@cur_category = c
			page = open_page( c.cat_link )
			return if page.blank?
			puts "CATEGORY: #{c.name_us.upcase}"
			BrowsePagesFromCategory( page )
		end
	end

	def BrowseItemsFromPage( page_link, i )
		local_thread_count = 0
		puts "new started #{i}"

		page = open_page( page_link )

		if page.blank?
			puts "page is blank"
			Log.error( "BrowseItemsFromPage: #{page_link}" )
			return
		end

		begin
			search_result = page.css("div#searchResults")
		rescue Exception => e
			Log.error( "BrowseItemsFromPage: \'#{e.message}\'" )
			return
		end

		item_links = search_result.css("a")
		item_links.each do |link|
			brandName = link.css("span.brandName").text
			bbb = process_brands( brandName )
			next if bbb == false

			product_id = link['data-product-id']
			style_id = link['data-style-id']

			ilink = "#{SITE_URL}#{link['href']}"
			image_link = link.css("img.productImg")[0]['src']
			image_full_path = "#{HOME_DIR}/#{(image_link.split(/\//).last).split("-").first}.jpg"
			image_path = "#{(image_link.split(/\//).last).split("-").first}.jpg"

			productName = link.css("span.productName").text
			price_usd = link.css("span.price-6pm").text.gsub!("$","").to_f
			price_ua = (get_price( link.css("span.price-6pm").text.gsub!("$","").to_f )).to_i
			discount = $1 if link.css("span.discount").text =~ /([\d]+)%/
			msrp_ua = (price_ua/((100-discount.to_f)/100.00)).to_i

			h_item = {
									:image_path => image_path,
									:product_id => product_id.to_i,
									:style_id => style_id.to_i,
									:productname => productName,
									:price_usd => price_usd,
									:price_ua => price_ua,
									:discount => discount,
									:msrp_ua => msrp_ua,
									:ilink => ilink
								}

			shoe = Shoes.new( h_item, ilink )

			if Item.is_present?( product_id, style_id )
				shoe.update_item
			else
				shoe.create_item
				local_thread_count += 1
				ImageDownload( image_link, image_full_path )
				bbb.items << shoe.get_item
				@cur_category.items << shoe.get_item
			end

		end
		puts "ended #{i}\ttotal items: #{local_thread_count}"
		Log.info( "p#{i}\ttotal items: #{local_thread_count}" )
	end

end


Log.info("PARSER STARED")
Log.info("CURRENT_PATH: #{ROOT}")

conf = Configer.new
conf.process_config

parse = ShopParser.new( conf )
parse.process_departments

Log.info("TOTAL ITEMS: #{Item.all.count}")
Log.info("PARSER ENDED")

system("ruby #{ROOT}/item_parser.rb")