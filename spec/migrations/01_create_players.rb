class CreatePlayers < BaseSimpleCacheMigration
  def change 
    create_table :players do |t|
      t.references :user
      t.string     :name
      t.boolean    :is_hero
    end
  end
end
