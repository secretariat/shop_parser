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
end

class Category < ActiveRecord::Base
	belongs_to :departments
	belongs_to :gender
	has_many :items
end

class Brand< ActiveRecord::Base
	has_many :items
end
