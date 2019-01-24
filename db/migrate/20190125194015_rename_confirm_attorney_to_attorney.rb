class RenameConfirmAttorneyToAttorney < ActiveRecord::Migration[5.2]
  def change
    rename_table :confirm_attorneys, :attorneys
  end
end
