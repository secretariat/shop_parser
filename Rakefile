require 'active_record'
require 'yaml'
require 'logger'

task :default => :migrate

task :migrate => :environment do
  ActiveRecord::Migrator.migrate('db/migrate', ENV["VERSION"] ? ENV["VERSION"].to_i : nil )
end

task :environment do
  ActiveRecord::Base.establish_connection(YAML::load(File.open('config/database.yml')))
  ActiveRecord::Base.logger = Logger.new(File.open('log/database.log', 'a'))
end

