class CreatePickemPicksWagers < ActiveRecord::Migration
  def up
    create_table :pickem_picks_wagers, :id => false do |t|
      t.integer :pickem_pick_id
      t.integer :wager_id
    end
    add_index :pickem_picks_wagers, [:pickem_pick_id, :wager_id]
  end

  def down
    drop_table :pickem_picks_wagers
  end
end
