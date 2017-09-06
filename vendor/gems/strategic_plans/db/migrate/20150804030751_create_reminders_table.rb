class CreateRemindersTable < ActiveRecord::Migration
  def change
    create_table :reminders do |t|
      t.string :text
      t.string :reminder_type
      t.date :start_date
      t.integer :activity_id
      t.timestamps
    end
  end
end
