class ConvertRemindersToPolymorphic < ActiveRecord::Migration
  def change
    rename_column :reminders, :activity_id, :remindable_id
    add_column :reminders, :type, :string
  end
end
