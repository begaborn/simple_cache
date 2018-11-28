require 'logger'

ActiveRecord::Base.establish_connection(:adapter => 'mysql2', :database => 'simple_cache_test', :username => "#{ENV['MYSQL_USER'] || 'root'}", :password => '')
ActiveRecord::Base.logger = Logger.new(File.open('database.log', 'a'))
#ActiveRecord::Base.logger = Logger.new(STDOUT)
