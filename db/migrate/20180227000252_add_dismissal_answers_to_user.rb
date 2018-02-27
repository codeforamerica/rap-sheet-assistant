class AddDismissalAnswersToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :on_parole, :boolean
    add_column :users, :on_probation, :boolean
    add_column :users, :finished_half_of_probation, :boolean
    add_column :users, :outstanding_warrant, :boolean
    add_column :users, :owe_fees, :boolean
  end
end
