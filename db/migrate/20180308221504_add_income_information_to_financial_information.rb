class AddIncomeInformationToFinancialInformation < ActiveRecord::Migration[5.1]
  def change
    add_column :financial_informations, :household_size, :integer
    add_column :financial_informations, :monthly_income_limit, :money
    add_column :financial_informations, :monthly_income_under_limit, :boolean
  end
end
