class ConvertRemindersToPolymorphic < ActiveRecord::Migration[4.2]
  def change
    rename_column :reminders, :activity_id, :remindable_id
    add_column :reminders, :remindable_type, :string
  end
end
