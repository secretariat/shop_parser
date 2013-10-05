# -*- encoding : utf-8 -*-
PATH = File.expand_path(File.dirname(__FILE__))
require "#{PATH}/header.rb"

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

Log.info("STYLE PARSER STARTED")
ar = [ Istyle, 	Material ]
ar.each do |style|
	Log.info("parsing '#{style}' started")
	parse_style( style )
	Log.info("parsing '#{style}' ended")
end

Log.info("STYLE PARSER ENDED")