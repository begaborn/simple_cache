require "bundler/setup"
require "simple_cache"
require "support/models"
require "pry-byebug"

SimpleCache.instance_variable_set(:@directory, File.dirname(__FILE__))

BaseSimpleCacheMigration = (SimpleCache.rails4? ? ActiveRecord::Migration : ActiveRecord::Migration[ActiveRecord::VERSION::STRING[0..2]]) 

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:each) do 
    SimpleCache.store.clear
  end
  
  config.before(:all) do
    migration_dir = "#{File.dirname(__FILE__)}/migrations"
    
    if SimpleCache.rails4?
      ActiveRecord::Migrator.migrate(migration_dir) 
    else
      ActiveRecord::MigrationContext.new(migration_dir).up
    end

    user = User.create!(name: 'user')

    Player.create!(user: user, name: "player1", is_hero: true) 
    Player.create!(user: user, name: "player2", is_hero: false) 
    Player.create!(user: user, name: "player3", is_hero: false) 

    3.times do |i|
      CreditCard.create!(user: user, name: "credit_card#{i}") 
    end

    3.times do |i|
      Weapon.create!(player: user.players.first, name: "weapon#{i}")
    end

    Account.create!(user: user)
  end

  config.after(:all) do
    migration_dir = "#{File.dirname(__FILE__)}/migrations"
    if SimpleCache.rails4?
      ActiveRecord::Migrator.down(migration_dir) 
    else
      ActiveRecord::MigrationContext.new(migration_dir).down
    end
  end
end
