class RemoveReminderIdFieldFromMediaAppearancesTable < ActiveRecord::Migration
  def change
    remove_column :media_appearances, :reminder_id
  end
end
