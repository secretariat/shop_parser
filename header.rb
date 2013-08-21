ROOT = File.expand_path(File.dirname(__FILE__))
# puts ROOT

#############################################################
require 'yaml'
require 'nokogiri'
require 'open-uri'
require 'active_record'
require 'fileutils'
require 'future_proof'

#############################################################
require "#{ROOT}/lib/shoes.rb"
require "#{ROOT}/lib/logwrite.rb"
require "#{ROOT}/lib/funcs.rb"
require "#{ROOT}/lib/configer.rb"
require "#{ROOT}/lib/db_configer.rb"
require "#{ROOT}/lib/common.rb"

#############################################################
SITE_URL = "http://6pm.com"
# HOME_DIR = File.join( Dir.home, "ror/garderob4ik/public/images" )
HOME_DIR = "/home/user/www/sites/garderob4ik/public/images"
#############################################################

@db_config = YAML::load(File.open("#{ROOT}/config/database.yml"))
ActiveRecord::Base.establish_connection( @db_config )

#############################################################