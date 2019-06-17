class RemoveUnusedFieldsFromUsersTable < ActiveRecord::Migration[4.2]
  def change
    remove_column :users, :pantry_id
  end
end
