require 'active_record'

class Departments < ActiveRecord::Base
	has_many :categories
end

class Gender < ActiveRecord::Base
	has_many :categories
end

class Category < ActiveRecord::Base
	belongs_to :departments
	belongs_to :gender
end

class Shoes < ActiveRecord::Base
	# belongs_to :category
end