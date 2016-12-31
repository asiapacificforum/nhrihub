class DropRemindersUsersTable < ActiveRecord::Migration[5.0]
  def change
    drop_table :reminders_users
    add_column :reminders, :user_id, :integer
  end
end
