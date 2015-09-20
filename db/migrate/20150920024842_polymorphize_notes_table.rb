class PolymorphizeNotesTable < ActiveRecord::Migration
  def change
    rename_column :notes, :activity_id, :notable_id
    add_column :notes, :notable_type, :string
  end
end
