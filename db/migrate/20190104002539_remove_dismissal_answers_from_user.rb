class RemoveDismissalAnswersFromUser < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :on_parole, :boolean
    remove_column :users, :on_probation, :boolean
    remove_column :users, :finished_half_of_probation, :boolean
    remove_column :users, :outstanding_warrant, :boolean
    remove_column :users, :owe_fees, :boolean
  end
end
