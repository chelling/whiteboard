class AddRecommendedPointsToPickemPick < ActiveRecord::Migration
  def up
    add_column :pickem_picks, :recommended_points, :integer
  end

  def down
    remove_column :pickem_picks, :recommended_points
  end
end
