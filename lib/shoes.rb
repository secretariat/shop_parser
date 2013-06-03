require 'open-uri'

class Shoes

	def initialize( item )
		@item = item
		check_item
	end

	def create_item
		item = Item.create( @item )
	end

	def update_item
		@item[:updated_at] = Time.now+1
		current_item = Item.where( :product_id => @item[:product_id], :style_id => @item[:style_id] ).first
		current_item.update_attributes( @item )
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

end