class AddLineToGame < ActiveRecord::Migration
  def up
    add_column :games, :line, :integer
  end
  
  def down
    remove_column :games, :line  
  end
end
