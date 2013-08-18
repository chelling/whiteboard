class AddNameToStadium < ActiveRecord::Migration
  def up
    add_column :stadiums, :name, :string
  end

  def down
    remove_column :stadiums, :name
  end
end
