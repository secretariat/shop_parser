module Common

	def get_style_and_materila_links( link )

		page = open_page( link )

		styles_block = page.css("div#FCTtxattrfacet_stylesSelect")
		style_links = styles_block.css("a")
		style_links.each do |link|
			style_link = "#{SITE_URL}#{link['href']}"
			style_name = link.text.split(/\(/)[0].strip
			if( !Style.exists?(:name_us => style_name ) )
				Style.create(:name_us => style_name, :link => style_link)
			end
		end

		material_block = page.css( "div#FCTtxattrfacet_materialsSelect" )
		material_links = material_block.css("a")
		material_links.each do |link|
			material_link = "#{SITE_URL}#{link['href']}"
			material_name = link.text.split(/\(/)[0].strip
			if( !Material.exists?(:name_us => material_name ) )
				cur_width = Material.create(:name_us => material_name, :link => material_link)
			end
		end

	end

	def pagination( page )
		pagin_block = page.css("div.pagination")
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

		return link_template, pages_num
	end
	
end