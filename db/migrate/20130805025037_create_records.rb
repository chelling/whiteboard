class CreateRecords < ActiveRecord::Migration
  def up
    create_table :records do |t|
      t.int :team_id
      t.int :year
      t.int :wins
      t.int :losses

      t.timestamps
    end
    add_index :records, ["team_id","year"]
  end
  
  def down
    drop_table :records
  end
end
