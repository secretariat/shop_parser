require 'open-uri'
require './lib/funcs.rb'

class Shoes

	attr_accessor :current_item

	def initialize( item, item_link )
		@item = item
		@item_link = item_link
		check_item
	end

	def create_item
		@current_item = Item.create( @item )
	end

	def update_item
		@item[:updated_at] = Time.now+1
		@current_item = Item.where( :product_id => @item[:product_id], :style_id => @item[:style_id] ).first
		@current_item.update_attributes( @item )
		@current_item.save
	end

	def get_item
		@current_item
	end

	def item_details

	end

	def delete_item
	end

	def check_item
		if( Item.exists?(:product_id => @item[:product_id], :style_id => @item[:style_id]) ) then
			update_item
		else
			create_item
		end
	end

	def get_shoes_description
		page = open_page( @item_link )
		sku = page.css("span#sku").text.split("#")[1].to_i
		# process_color( item, page )
		# process_size( item, page )
		main_image_div = page.css("div#detailImage")
		# puts main_image_path = main_image_div.css("img")[0]['src']
		description_block = page.css("div.description")
		thumbnails_block = page.css("div#productImages")
		image_links_block = thumbnails_block.css('img')
		desc = Description.new( :sku => sku.to_i, :description => description_block.to_s )
		@current_item.description = desc
		image_links_block.each do |link|
			if link['src'] =~ /MULTIVIEW_THUMBNAILS/
				thumb_image_name = "#{link['src'].split(/\//).last.split(/-/)[0..1].join("-")}-thumb.jpg"
				large_image_name = "#{link['src'].split(/\//).last.split(/-/)[0..1].join("-")}.jpg"
				thumb_image_full_path = "#{HOME_DIR}/descriptions/#{thumb_image_name}"
				large_image_full_path = "#{HOME_DIR}/descriptions/#{large_image_name}"
				large_image_download_link = link['src'].gsub("_THUMBNAILS","")
				desc.images << Image.new( :thumb_path => thumb_image_name, :image_path => large_image_name )
				ImageDownload( link['src'], thumb_image_full_path )
				ImageDownload( large_image_download_link, large_image_full_path )
			end
		end
	end

end