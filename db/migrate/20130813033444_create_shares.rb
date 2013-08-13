class CreateShares < ActiveRecord::Migration
  def up
    create_table :shares do |t|
      t.integer :year
      t.integer :user_id
      t.integer :game_id
      t.integer :team_id

      t.timestamps
    end
    add_index :shares, ["user_id","team_id","game_id"]
  end

  def down
    drop_table :shares
  end
end
