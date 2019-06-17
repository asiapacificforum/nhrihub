class ChangeUserStatusDefaultToCreated < ActiveRecord::Migration[4.2]
  def change
    change_column_default :users, :status, 'created'
  end
end
