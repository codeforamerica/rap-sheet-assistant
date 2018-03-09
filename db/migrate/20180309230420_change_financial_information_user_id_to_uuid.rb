class ChangeFinancialInformationUserIdToUuid < ActiveRecord::Migration[5.1]
  def up
    drop_table :financial_informations

    create_table :financial_informations, id: :uuid do |t|
      t.belongs_to :user, type: :uuid
      t.string :job_title
      t.string :employer_name
      t.string :employer_address
      t.boolean :employed, null: false
      t.string :benefits_programs, default: [], array: true
      t.integer :household_size
      t.money :monthly_income_limit
      t.boolean :monthly_income_under_limit

      t.timestamps
    end
  end

  def down

  end
end
