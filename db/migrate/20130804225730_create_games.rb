class CreateGames < ActiveRecord::Migration
  def up
    create_table :games do |t|
      t.integer :year
      t.integer :week
      t.string :location
      t.integer :home_team_id
      t.integer :away_team_id
      t.integer :home_score
      t.integer :away_score
      t.datetime :date

      t.timestamps
    end
    add_index :games, ["year","week"]
  end
  
  def down
    drop_table :games
  end
end
