class Configer

	attr_accessor :cat_by_gender

	def initialize
		@departs = YAML::load(File.open("#{ROOT}/config/departments.yml"))
		@brands = YAML::load(File.open("#{ROOT}/config/brands.yml"))
		@gender = YAML::load(File.open("#{ROOT}/config/gender.yml"))
		@db_config = YAML::load(File.open("#{ROOT}/config/database.yml"))
		@cat_by_gender = YAML::load(File.open("#{ROOT}/config/category_by_gender.yml"))
		ActiveRecord::Base.establish_connection( @db_config )
	end

	def get_brands
		@brands.each do |s|
			if !Brand.exists?( :name => s )
				Brand.create( :name => s )
			end
		end
	end

	def get_gender_table
		1.upto(@gender['gender'].size) do |i|
			if !Gender.exists?( :id => i )
				Gender.create( :gender_name => @gender['gender'][i] )
			end
		end
	end

	def get_departments
		@departs.each do |dep|
			cur_dep = Departments.find_by_id( dep[1]['id'] )
			if cur_dep.present?
				if (cur_dep.link != dep[1]['link']) || (cur_dep.active != dep[1]['active'])
					Departments.update( dep[1]['id'], :link => dep[1]['link'], :active => dep[1]['active'] )
				end
			else
				Departments.create( :id => dep[1]['id'], :name_us => dep[1]['name_en'], :name_ru => dep[1]['name_ru'], :link => dep[1]['link'], :active => dep[1]['active'] )
			end
		end
	end

	def lspath_create
		FileUtils.mkdir_p HOME_DIR
		FileUtils.mkdir_p "#{HOME_DIR}/descriptions"
	end

	def process_config
		lspath_create
		get_brands
		get_gender_table
		get_departments
	end

end
