class CreateStadiums < ActiveRecord::Migration
  def up
    create_table :stadiums do |t|
      t.integer :team_id
      t.string :location
      t.string :time_zone
      t.string :stadium_type
      t.string :grass_type

      t.timestamps
    end
  end

  def down
    drop_table :stadiums
  end
end
