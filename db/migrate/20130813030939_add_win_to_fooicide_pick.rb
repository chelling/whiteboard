class AddWinToFooicidePick < ActiveRecord::Migration
  def up
    add_column :fooicide_picks, :win, :boolean
  end

  def down
    remove_column :fooicide_picks, :win
  end
end
