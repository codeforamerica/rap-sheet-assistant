class UpdateUserContactInfo < ActiveRecord::Migration[5.2]
  def change
    rename_column :users, :first_name, :name
    rename_column :users, :zip_code, :zip
  end
end
