class CreateRemindersUsersJoinTable < ActiveRecord::Migration[4.2]
  def change
    create_table :reminders_users, :id => false, :force => true do |t|
      t.integer :reminder_id
      t.integer :user_id
    end
  end
end
