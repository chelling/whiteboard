class AddPreviousValuesToWagers < ActiveRecord::Migration
  def up
    add_column :wagers, :previous_amount, :decimal
  end

  def down
    remove_column :wagers, :previous_amount
  end
end
