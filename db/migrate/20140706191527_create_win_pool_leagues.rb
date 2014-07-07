class CreateWinPoolLeagues < ActiveRecord::Migration
  def up
    create_table :win_pool_leagues do |t|
      t.string :name
      t.integer :year

      t.timestamps
    end
    add_index :win_pool_leagues, :year
  end

  def down
    drop_table :win_pool_leagues
  end
end
