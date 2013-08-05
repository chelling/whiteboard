class CreateFooicidePicks < ActiveRecord::Migration
  def up
    create_table :fooicide_picks do |t|
      t.integer :year
      t.integer :week
      t.integer :game_id
      t.integer :user_id
      t.integer :team_id

      t.timestamps
    end
    add_index :fooicide_picks, ["year","week","user_id"]
  end
  
  def down
    drop_table :fooicide_picks
  end
end
