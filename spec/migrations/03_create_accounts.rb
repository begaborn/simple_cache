class CreateAccounts < BaseSimpleCacheMigration
  def change 
    create_table :accounts do |t|
      t.references :user
      t.string     :name
    end
  end
end
