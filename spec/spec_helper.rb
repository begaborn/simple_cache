require "pry"
require "bundler/setup"
require "simple_cache"
require "support/models"
require "rspec/its"

SimpleCache.instance_variable_set(:@directory, File.dirname(__FILE__))

BaseSimpleCacheMigration = (SimpleCache.rails_version.v4? ? ActiveRecord::Migration : ActiveRecord::Migration[ActiveRecord::VERSION::STRING[0..2]])

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

    if SimpleCache.rails_version.v4?
      ActiveRecord::Migrator.migrate(migration_dir)
    else
      ActiveRecord::MigrationContext.new(migration_dir).up
    end

    user = User.create({ name: 'SimpleCache user', age: 1 })

    players = Player.create([
      { user: user, name: 'SimpleCache player1', is_hero: true },
      { user: user, name: 'SimpleCache player2', is_hero: false },
      { user: user, name: 'SimpleCache player3', is_hero: false }
    ])

    weapons = Weapon.create!([
      { name: 'SimpleCache sword1', type: 'Weapon::Sword' },
      { name: 'SimpleCache armor1', type: 'Weapon::Armor' },
      { name: 'SimpleCache sword2', type: 'Weapon::Sword' }
    ])

    potions = Potion.create!([
      { name: 'SimpleCache hp1' },
      { name: 'SimpleCache mp1' },
      { name: 'SimpleCache antidote1' }
    ])

    Item.create!([
      { player: players.first, item: weapons.first },
      { player: players.first, item: potions.first },
      { player: players.first, item: weapons.first }
    ])

    Account.create({user: user, name: 'Account name'})

    credit_cards = CreditCard.create([
      {user: user, name: 'Epos Visa Card', expire_date: Date.new(2018, 10, 10)},
      {user: user, name: 'MUFG Mater Card', expire_date: Date.new(2030, 11, 11)}
    ])

    CreditCard.create({user: user, name: 'Epos Visa Card', expire_date: Date.new(2030, 10, 10), previous: credit_cards.first })
  end

  config.after(:all) do
    migration_dir = "#{File.dirname(__FILE__)}/migrations"
    if SimpleCache.rails_version.v4?
      ActiveRecord::Migrator.down(migration_dir)
    else
      ActiveRecord::MigrationContext.new(migration_dir).down
    end
  end
end
