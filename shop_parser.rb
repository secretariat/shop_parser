# -*- encoding : utf-8 -*-

require 'yaml'
require 'nokogiri'
require 'open-uri'
require 'active_record'
require './lib/funcs.rb'
require './lib/configer.rb'

#############################################################
SITE_URL = "http://6pm.com"
#############################################################

class ShopParser

	def initialize( global_config )
		@db_config = YAML::load(File.open('./config/database.yml'))
		@gconfig = global_config
		ActiveRecord::Base.establish_connection( @db_config )
		@cur_dep = nil
		@cur_gender = nil
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
		get_subdepartments_links( dep_link )
	end

	def get_subdepartments_links( department_link )
		page = Nokogiri::HTML(open( department_link ))
		left_block = page.css("div#tcSideCol")
		view_all_links = left_block.css("a")
		view_all_links.each do |link|
			if link['class'] =~ /view-all last/
				full_link = "#{SITE_URL}#{link['href']}"
				gender = Gender.find_by_gender_name( get_gender_from_link( full_link ) )
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
			# BrowseItemsFromPage( ready_link, cat_id )
			break
		end
	end

	def pagination page
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


end

conf = Configer.new
conf.process_config

parse = ShopParser.new( conf )
parse.process_departments
# parse.get_subdepartments
