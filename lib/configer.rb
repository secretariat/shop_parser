require 'yaml'
require 'fileutils'
require 'active_record'
# require File.expand_path('db_configer.rb', File.dirname(__FILE__))
require './lib/db_configer.rb'

class Configer
	attr_accessor :cat_by_gender
	def initialize
		@departs = YAML::load(File.open('./config/departments.yml'))
		@brands = YAML::load(File.open('./config/brands.yml'))
		@gender = YAML::load(File.open('./config/gender.yml'))
		@db_config = YAML::load(File.open('./config/database.yml'))
		@cat_by_gender = YAML::load(File.open('./config/category_by_gender.yml'))
		ActiveRecord::Base.establish_connection( @db_config )
	end

	def get_brands
		@brands.each do |s|
			if !Brand.exists?( :brand_name => s )
				Brand.create( :brand_name => s )
			end
		end
	end

	def get_gender_table
		1.upto(@gender['gender'].size) do |i|
			if !Gender.exists?( :id => i )
				Gender.create( :gender_name => @gender['gender'][i] )
			end
		end
	end

	def get_departments
		@departs.each do |dep|
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

	def lspath_create
		FileUtils.mkdir_p HOME_DIR
		FileUtils.mkdir_p "#{HOME_DIR}/descriptions"
	end

	def process_config
		lspath_create
		get_brands
		get_gender_table
		get_departments
	end

end
