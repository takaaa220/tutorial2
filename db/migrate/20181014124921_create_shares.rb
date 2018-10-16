class CreateShares < ActiveRecord::Migration[5.2]
  def change
    create_table :shares do |t|
      t.integer :user_id
      t.integer :micropost_id

      t.timestamps
    end
    add_index :shares, :user_id
    add_index :shares, :micropost_id
    add_index :shares, [:user_id, :micropost_id], unique: true
  end
end
