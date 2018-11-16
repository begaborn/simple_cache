class CreateItems < ActiveRecord::Migration[5.2]
  def change
    create_table :items do |t|
      t.references :player, null: true
      t.string  :item_type
      t.integer :item_id
      t.timestamps
    end
  end
end
