class AddFinancialInformationTable < ActiveRecord::Migration[5.1]
  def change
    create_table :financial_informations, id: :uuid do |t|
      t.belongs_to :user
      t.string :job_title
      t.string :employer_name
      t.string :employer_address
      t.boolean :employed, null: false

      t.timestamps
    end
  end
end
