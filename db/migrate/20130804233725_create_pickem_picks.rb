class CreatePickemPicks < ActiveRecord::Migration
  def up
    create_table :pickem_picks do |t|
      t.integer :year
      t.integer :week
      t.integer :game_id
      t.integer :user_id
      t.integer :team_id

      t.timestamps
    end
    add_index :pickem_picks, ["year","week","user_id"]
  end
  
  def down
    drop_table :pickem_picks
  end
end
