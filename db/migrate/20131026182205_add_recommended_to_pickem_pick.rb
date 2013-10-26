class AddRecommendedToPickemPick < ActiveRecord::Migration
  def up
    add_column :pickem_picks, :recommended, :boolean
  end
  
  def down
    remove_column :pickem_picks
  end
end
