require 'thread'
require 'future_proof'
require 'open-uri'
require 'yaml'
require 'nokogiri'
require 'active_record'
require './lib/shoes.rb'
require './lib/configer.rb'
require './lib/funcs.rb'
require './lib/common.rb'

#############################################################
SITE_URL = "http://6pm.com"
# HOME_DIR = File.join( Dir.home, "ror/garderob4ik/public/images" )
HOME_DIR = "/var/www/sites/garderob4ik/public/images"
#############################################################

@db_config = YAML::load(File.open('./config/database.yml'))
ActiveRecord::Base.establish_connection( @db_config )

include Common

def process_demension( demension )
	page = open_page( demension.link )
	browse_paginated_pages( page, demension )
end

def parse_style( demension )
	@dems = demension.all
	@dems.each do |dem|
		process_demension( dem )
	end
end

# parse_style( Style )
ar = [ Style, Material ]
ar.each { |a| parse_style( a ) }