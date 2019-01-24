class AddProSeToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :pro_se, :boolean
  end
end
