class UpdatePreferredContactTypes < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :preferred_contact_method
    add_column :users, :prefer_email, :boolean
    add_column :users, :prefer_text, :boolean
  end
end
