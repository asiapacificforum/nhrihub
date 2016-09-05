class AddNextColumnToReminder < ActiveRecord::Migration[5.0]
  def change
    add_column :reminders, :next, :datetime
  end
end
