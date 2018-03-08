class AddBenefitsQuestionsToFinancialQuestions < ActiveRecord::Migration[5.1]
  def change
    add_column :financial_informations, :benefits_programs, :string, array: true, default: []
  end
end
