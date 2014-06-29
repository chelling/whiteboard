class CreateWagers < ActiveRecord::Migration
  def up
    create_table :wagers do |t|
      t.integer :account_id
      t.integer :pickem_pick_id
      t.decimal :amount
      t.decimal :potential_payout
      t.decimal :payout
      t.integer :win

      t.timestamps
    end
    add_index :wagers, ["account_id", "pickem_pick_id"]
  end

  def down
    drop_table :wagers
  end
end
