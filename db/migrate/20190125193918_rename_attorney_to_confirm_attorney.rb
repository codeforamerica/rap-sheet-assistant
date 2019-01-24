class RenameAttorneyToConfirmAttorney < ActiveRecord::Migration[5.2]
  def change
    rename_table :attorneys, :confirm_attorneys
  end
end
