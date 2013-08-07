class CreateRecords < ActiveRecord::Migration
  def up
    create_table :records do |t|
      t.integer :team_id
      t.integer :year
      t.integer :wins
      t.integer :losses

      t.timestamps
    end
    add_index :records, ["team_id","year"]
  end
  
  def down
    drop_table :records
  end
end
