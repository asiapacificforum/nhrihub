class CreateRemindersUsersJoinTable < ActiveRecord::Migration
  def change
    create_table :reminders_users, :id => false do |t|
      t.integer :reminder_id
      t.integer :user_id
    end
  end
end
