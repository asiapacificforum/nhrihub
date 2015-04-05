class RemoveUnusedFieldsFromUsersTable < ActiveRecord::Migration
  def change
    remove_column :users, :pantry_id
  end
end
