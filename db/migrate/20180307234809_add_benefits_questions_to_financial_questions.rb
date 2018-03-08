class AddBenefitsQuestionsToFinancialQuestions < ActiveRecord::Migration[5.1]
  def change
    add_column :financial_informations, :on_public_benefits, :boolean
    add_column :financial_informations, :benefits_programs, :string, array: true
  end
end
