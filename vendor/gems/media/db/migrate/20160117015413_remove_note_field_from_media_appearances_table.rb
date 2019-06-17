class RemoveNoteFieldFromMediaAppearancesTable < ActiveRecord::Migration[4.2]
  def change
    remove_column :media_appearances, :note
  end
end
