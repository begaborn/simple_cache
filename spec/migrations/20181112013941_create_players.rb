class CreatePlayers < ActiveRecord::Migration[5.2]
  def change
    create_table :players do |t|
      t.references :user
      t.string :name
      t.boolean :is_hero

      t.timestamps
    end
  end
end
