class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users, id: :uuid do |t|
      t.string :first_name
      t.string :last_name
      t.string :phone_number
      t.string :email
      t.string :street_address
      t.string :city
      t.string :state
      t.string :zip_code
      t.date :date_of_birth

      t.timestamps
    end
  end
end
