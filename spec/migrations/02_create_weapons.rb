class CreateWeapons < BaseSimpleCacheMigration
  def change 
    create_table :weapons do |t|
      t.references :player
      t.integer    :u_id
      t.string     :name
    end
  end
end
