# -*- encoding : utf-8 -*-

require 'yaml'
require 'nokogiri'
require 'open-uri'
require 'active_record'
require './lib/funcs.rb'

#############################################################
SITE_URL = "http://6pm.com"
#############################################################


class Departments < ActiveRecord::Base
	has_many :subdepartments
end

class Subdepartments < ActiveRecord::Base
	belongs_to :departments
end

class Category < ActiveRecord::Base
	# has_many :shoess
end

class Shoes < ActiveRecord::Base
	# belongs_to :category
end

class ShopParser

	def initialize
		@config = YAML::load(File.open('./config/config.yml'))
		@db_config = YAML::load(File.open('./config/database.yml'))
		ActiveRecord::Base.establish_connection( @db_config )
		# @cur_gender = nil
	end

	def get_departments
		@config.each do |dep|
			cur_dep = Departments.find_by_id( dep[1]['id'] )
			if cur_dep.present?
				if (cur_dep.dep_link != dep[1]['link']) || (cur_dep.active != dep[1]['active'])
					Departments.update( dep[1]['id'], :dep_link => dep[1]['link'], :active => dep[1]['active'] )
				end
			else
				Departments.create( :id => dep[1]['id'], :dep_name_en => dep[1]['name_en'], :dep_name_ru => dep[1]['name_ru'], :dep_link => dep[1]['link'], :active => dep[1]['active'] )
			end
		end
	end

	def get_subdepartments_links( department_link )
		page = Nokogiri::HTML(open( department_link ))
		left_block = page.css("div#tcSideCol")
		view_all_links = left_block.css("a")
		view_all_links.each do |link|
			if link['class'] =~ /view-all last/
				full_link = "#{SITE_URL}#{link['href']}"
				puts full_link
				# GetGenderCategories( full_link )
			end
		end
	end

	def get_subdepartments
		deps = Departments.where( :active => true )
		deps.each do |d|
			get_subdepartments_links( d.dep_link )
		end
	end

	def GetGenderCategories( gender_cat_link )
		page = Nokogiri::HTML( open( gender_cat_link ) )
		category_block = page.css("div#FCTzc2Select")
		male_category_links = category_block.css("a")
		male_category_links.each do |link|
			cat_name = link.text.strip
			cat_name = cat_name.split("(")[0].chomp
			cat_link = "#{SITE_URL}#{link['href']}"
			if !Category.exists?( :cat_link => cat_link )
				Category.create( :cat_name_en => cat_name, :cat_link => cat_link)
			end
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

end

parse = ShopParser.new
parse.get_departments
parse.get_subdepartments