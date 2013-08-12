class AddTieToPickemPick < ActiveRecord::Migration
  def up
    add_column :pickem_picks, :tie, :boolean
  end

  def down
    remove_column :pickem_picks, :tie
  end
end
