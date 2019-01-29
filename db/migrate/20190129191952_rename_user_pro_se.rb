class RenameUserProSe < ActiveRecord::Migration[5.2]
  def change
    rename_column :users, :pro_se, :has_attorney
  end
end
