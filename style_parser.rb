# -*- encoding : utf-8 -*-
require "./header"

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