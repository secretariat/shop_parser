module Common

	def get_style_and_material_links( link )

		page = open_page( link )

		return if page.blank?

		styles_block = page.css("div#FCTtxattrfacet_stylesSelect")
		style_links = styles_block.css("a")
		style_links.each do |link|
			style_link = "#{SITE_URL}#{link['href']}"
			style_name = link.text.split(/\(/)[0].strip
			if( !Istyle.exists?(:name_us => style_name ) )
				Istyle.create(:name_us => style_name, :link => style_link)
			end
		end

		material_block = page.css( "div#FCTtxattrfacet_materialsSelect" )
		material_links = material_block.css("a")
		material_links.each do |link|
			material_link = "#{SITE_URL}#{link['href']}"
			material_name = link.text.split(/\(/)[0].strip
			if( !Material.exists?(:name_us => material_name ) )
				Material.create(:name_us => material_name, :link => material_link)
			end
		end

	end

	def browse_paginated_pages( page, demension )
		link_template, pages_num = pagination( page )
	 	cur_page_link = link_template.gsub!(/page[0-9]/, "pageX")
	 	cur_page_link_tmp = link_template.gsub!(/p=[0-9]/, "p=Z")
		1.upto(pages_num) do |i|
			page_link = cur_page_link_tmp.gsub(/pageX/, "page#{i}")
			page_link = page_link.gsub(/p=Z/, "p=#{i-1}")
			ready_link = "#{SITE_URL}#{page_link}"
			process_items_for_demension( ready_link, demension )
		end
	end

	def pagination( page )
		begin
			pagin_block = page.css("div.pagination")
		rescue Exception => e
			Log.error( "pagination: \'#{e.message}\'" )
			return
		end
		link_template = ""
		pages_num = 0
		pagin_block.each do |pag|
			links = pag.css("a")
			ar = Array.new
			links.each do |link|
				ar << link.text.to_i
			end

			pages_num = ar.max

			link_template = links[0]['href']
			puts link_template
			break
		end
		Log.info( "pages for current category: #{pages_num}" )
		return link_template, pages_num
	end

	def process_items_for_demension( page_link, demension )

		page = open_page( page_link )

		return if page.blank?

		begin
			search_result = page.css("div#searchResults")
		rescue Exception => e
			Log.error( "process_items_for_demension: \'#{e.message}\'" )
			return
		end

		item_links = search_result.css("a")
		item_links.each do |link|
			product_id = link['data-product-id']
			style_id = link['data-style-id']
			item = Item.find( :all, :conditions => { :product_id => product_id, :style_id => style_id } )

			next if item.blank?

			if demension.class == Istyle
				if !item[0].istyle.blank?
					# Log.info( "Item Style Exists #{item[0].istyle.name_us}" )
					next
				end
			elsif demension.class == Material
				if !item[0].material.blank?
					# Log.info("Item Material Exists #{item[0].material.name_us}")
					next
				end
			end

			demension.items << item
			Log.info( "Item Style created" )
		end
	end

end