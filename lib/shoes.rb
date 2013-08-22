class Shoes

	attr_accessor :current_item

	def initialize( item, item_link )
		@item = item
		@page = open_page( item_link )
	end

	def create_item
		# puts "new"
		@current_item = Item.create( @item )
	end

	def update_item
		@current_item = Item.where( :product_id => @item[:product_id], :style_id => @item[:style_id] ).first
		@item[:updated_at] = Time.now+1
		@current_item.update_attributes( @item )
		@current_item.save
		# puts "exists"
	end

	def get_item
		@current_item
	end

	def delete_item
	end

end