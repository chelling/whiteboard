class UpdateLineToDouble < ActiveRecord::Migration
  def up
    change_column :games, :line, :float
  end

  def down
    change_column :games, :line, :int
  end
end
