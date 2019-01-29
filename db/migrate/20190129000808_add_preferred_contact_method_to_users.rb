class AddPreferredContactMethodToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :preferred_contact_method, :string
  end
end
