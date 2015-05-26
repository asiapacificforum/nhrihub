class ChangeUserStatusDefaultToCreated < ActiveRecord::Migration
  def change
    change_column_default :users, :status, 'created'
  end
end
