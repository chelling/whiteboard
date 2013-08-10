class AddWinToPickem < ActiveRecord::Migration
  def up
    add_column :pickem_picks, :win, :boolean  
  end

  def down
    remove_column :pickem_picks, :win
  end
end
