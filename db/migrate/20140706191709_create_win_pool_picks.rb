class CreateWinPoolPicks < ActiveRecord::Migration
  def up
    create_table :win_pool_picks do |t|
      t.integer :user_id
      t.integer :win_pool_league_id
      t.integer :starting_position
      t.integer :year
      t.integer :team_one_id
      t.integer :team_two_id
      t.integer :team_three_id

      t.timestamps
    end
    add_index :win_pool_picks, ["win_pool_league_id", "user_id", "year"]
  end

  def down
    drop_table :win_pool_picks
  end
end
