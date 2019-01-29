class AddContactInfoToAttorney < ActiveRecord::Migration[5.2]
  def change
    add_column :attorneys, :street_address, :string
    add_column :attorneys, :city, :string
    add_column :attorneys, :state, :string
    add_column :attorneys, :zip, :string
    add_column :attorneys, :phone_number, :string
    add_column :attorneys, :email, :string
  end
end
