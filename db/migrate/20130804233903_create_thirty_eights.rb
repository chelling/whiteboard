class CreateThirtyEights < ActiveRecord::Migration
  def up
    create_table :thirty_eights do |t|
      t.integer :year
      t.integer :team_id
      t.integer :user_id
      t.integer :shares

      t.timestamps
    end
    add_index :thirty_eights, ["year","user_id"]
  end
  
  def down
    drop_table :thirty_eights
  end
end
