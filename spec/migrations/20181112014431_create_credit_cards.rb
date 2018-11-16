class CreateCreditCards < ActiveRecord::Migration[5.2]
  def change
    create_table :credit_cards do |t|
      t.references :user
      t.string     :name
      t.date       :expire_date
      t.integer    :after_id, defaut: 0
      t.timestamps
    end
  end
end
