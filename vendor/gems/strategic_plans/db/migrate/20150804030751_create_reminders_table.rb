class CreateRemindersTable < ActiveRecord::Migration[4.2]
  def change
    create_table :reminders, :force => true do |t|
      t.string :text
      t.string :reminder_type
      t.date :start_date
      t.integer :activity_id
      t.timestamps
    end
  end
end
