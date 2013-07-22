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


def get_item_details( page, item )

	process_color(page, item)
	process_size(page, item)

	sku = page.css("span#sku").text.split("#")[1].to_i
	main_image_div = page.css("div#detailImage")
	# puts main_image_path = main_image_div.css("img")[0]['src']
	description_block = page.css("div.description")
	thumbnails_block = page.css("div#productImages")
	image_links_block = thumbnails_block.css('img')
	desc = Description.new( :sku => sku.to_i, :description => description_block.to_s )
	item.description = desc
	image_links_block.each do |link|
		if link['src'] =~ /MULTIVIEW_THUMBNAILS/

			thumb_image_name = "#{link['src'].split(/\//).last.split(/-/)[0..1].join("-")}-thumb.jpg"
			large_image_name = "#{link['src'].split(/\//).last.split(/-/)[0..1].join("-")}.jpg"
			zoom_image_name = "#{link['src'].split(/\//).last.split(/-/)[0..1].join("-")}-4x.jpg"

			thumb_image_full_path = "#{HOME_DIR}/descriptions/#{thumb_image_name}"
			large_image_full_path = "#{HOME_DIR}/descriptions/#{large_image_name}"
			zoom_image_full_path = "#{HOME_DIR}/descriptions/#{zoom_image_name}"

			large_image_download_link = link['src'].gsub("_THUMBNAILS","")
			zoom_image_download_link = link['src'].gsub("MULTIVIEW_THUMBNAILS","4x")

			ImageDownload( link['src'], thumb_image_full_path )
			ImageDownload( large_image_download_link, large_image_full_path )
			ImageDownload( zoom_image_download_link, zoom_image_full_path )
			desc.images << Image.new( :thumb_path => thumb_image_name, :image_path => large_image_name, :zoom_path => zoom_image_name,  )
		end
	end
end

def process_color( page, item )
	cur_color = nil
	color_values = nil

	color_block = page.css("select#color")
	if !color_block.present? then
		color_block = page.css("li#colors")
		color_values = color_block.css("p.note")
		# puts color_values
	else
		color_values = color_block.css("option")
		# puts color_values
	end

	color_values.each do |color|
		if( !Color.exists?(:color_name => color.text) )
			cur_color = Color.create( :color_name => color.text )
		else
			cur_color = Color.find_by_color_name( color.text )
		end

		item.colors << cur_color
	end

end

def process_size( page, item )

	size_block = page.css("select#d3")
	if !size_block.present? then
		size_block = page.css("li#colors")
		size_values = size_block.css("p.note")
		# puts color_values
	else
		size_values = size_block.css("option")
		# puts size_values
	end

	size_values.each do |size|
		if !(size.text =~ /select/i) then
			if( !Size.exists?(:size_value => size.text) )
				cur_size = Size.create( :size_value => size.text )
			else
				cur_size = Size.find_by_size_value( size.text )
			end

			item.sizes << cur_size
		end
	end
end

def get_items
	@items = Item.all
	threads = []
	@items.each do |item|
		if threads.size < 4 then
			threads << Thread.new(item) do |i|
				puts i.productname
				page = open_page( i.ilink )
				get_item_details( page, i )
			end
		else
			break
		end
	end
	threads.each { |t| t.join  }
end

get_items


