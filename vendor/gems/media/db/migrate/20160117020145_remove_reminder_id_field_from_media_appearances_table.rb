class RemoveReminderIdFieldFromMediaAppearancesTable < ActiveRecord::Migration[4.2]
  def change
    remove_column :media_appearances, :reminder_id
  end
end
