require 'active_record'

class Departments < ActiveRecord::Base
	has_many :categories
end

class Gender < ActiveRecord::Base
	has_many :categories
end

class Item < ActiveRecord::Base
	belongs_to :category
	belongs_to :brand
	has_many :colors
	has_many :sizes
	has_one :description
end

class Category < ActiveRecord::Base
	belongs_to :departments
	belongs_to :gender
	has_many :items
end

class Brand< ActiveRecord::Base
	has_many :items
end

class Description< ActiveRecord::Base
	belongs_to :item
	has_many :images
end

class Image< ActiveRecord::Base
	belongs_to :description
end

class Color< ActiveRecord::Base
	belongs_to :item
end

class Size< ActiveRecord::Base
	belongs_to :item
end
