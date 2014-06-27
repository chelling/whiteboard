class CreateAccounts < ActiveRecord::Migration
  def up
    create_table :accounts do |t|
      t.integer :user_id
      t.integer :year
      t.decimal :amount

      t.timestamps
    end
    add_index :accounts, "user_id"
  end

  def down
    drop_table :accounts
  end
end
