class CreateTeams < ActiveRecord::Migration
  def up
    create_table :teams do |t|
      t.string :name
      t.string :location
      t.string :image
      t.string :conference
      t.string :division

      t.timestamps
    end
    add_index :teams, ["conference","division"]
  end
  
  def down 
    drop_table :teams
  end
end
