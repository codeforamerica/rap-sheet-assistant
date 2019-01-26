class CreateAttorneys < ActiveRecord::Migration[5.2]
  def change
    create_table :attorneys, id: :uuid do |t|
      t.string :name
      t.string :state_bar_number
      t.string :firm_name

      t.timestamps
    end

    add_belongs_to :users, :attorney, type: :uuid
  end
end
