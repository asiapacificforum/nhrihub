class CreateNotesTable < ActiveRecord::Migration
  def change
    create_table :notes do |t|
      t.text :text
      t.integer :activity_id
      t.integer :author_id
      t.integer :editor_id
      t.timestamps :null => false
    end
  end
end
