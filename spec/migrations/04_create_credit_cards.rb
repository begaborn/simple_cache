class CreateCreditCards < BaseSimpleCacheMigration
  def change 
    create_table :credit_cards do |t|
      t.references :user
      t.string     :name
    end
  end
end
