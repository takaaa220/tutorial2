class ChangeTables < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :picture
    add_column :microposts, :picture, :string
  end
end
