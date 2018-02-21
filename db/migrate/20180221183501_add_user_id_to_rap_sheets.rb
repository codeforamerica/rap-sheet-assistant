class AddUserIdToRapSheets < ActiveRecord::Migration[5.1]
  class RapSheet < ActiveRecord::Base; end
  class User < ActiveRecord::Base; end

  def up
    add_reference :rap_sheets, :user, foreign_key: true, type: :uuid
    RapSheet.find_each do |rap_sheet|
      rap_sheet.update(user_id: User.create!.id)
    end
    change_column_null :rap_sheets, :user_id, :false
  end

  def down
    remove_reference :rap_sheets, :user
  end
end
