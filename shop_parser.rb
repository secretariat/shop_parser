# -*- encoding : utf-8 -*-

require 'yaml'
require 'active_record'

class Departments < ActiveRecord::Base
end

class ShopParser

	def initialize
		@config = YAML::load(File.open('./config/config.yml'))	
		@db_config = YAML::load(File.open('./config/database.yml'))
		ActiveRecord::Base.establish_connection( @db_config )
		config_to_screen
	end
	
	def config_to_screen
		# puts @config
		@config.each do |dep|
			cur_dep = Departments.where( :id => dep[1]['id'].to_i)
			if cur_dep != nil 
				if cur_dep.dep_link != dep[1]['link']
					Departments.create(:dep_name_en => dep[1]['name_en'], :dep_link => dep[1]['link'] )
					puts "YEP"
				end
			end
		end
	end
end

ShopParser.new