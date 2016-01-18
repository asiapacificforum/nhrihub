class RemoveNoteFieldFromMediaAppearancesTable < ActiveRecord::Migration
  def change
    remove_column :media_appearances, :note
  end
end
