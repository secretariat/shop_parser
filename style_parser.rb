require 'thread'
require 'future_proof'
require 'open-uri'
require 'yaml'
require 'nokogiri'
require 'active_record'
require './lib/shoes.rb'
require './lib/configer.rb'
require './lib/funcs.rb'

#############################################################
SITE_URL = "http://6pm.com"
HOME_DIR = File.join( Dir.home, "ror/garderob4ik/public/images" )
# HOME_DIR = "/var/www/sites/garderob4ik/public/images"
#############################################################

@db_config = YAML::load(File.open('./config/database.yml'))
ActiveRecord::Base.establish_connection( @db_config )




# thread_pool = FutureProof::ThreadPool.new(1)
# @items = Item.all
# @items.each do |item|
#   thread_pool.submit item do |i|
#    	get_item_details( i )
#   end
# end

# thread_pool.perform
# thread_pool.values