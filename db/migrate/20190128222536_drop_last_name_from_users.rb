class DropLastNameFromUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :last_name
    remove_column :users, :middle_name
  end
end
