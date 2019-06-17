class CreateMediaAppearances < ActiveRecord::Migration[4.2]
  def change
    create_table :media_appearances, :force => true do |t|
      # stored, scanned document info:
      t.string   :file_id,           limit: 255
      t.integer  :filesize
      t.string   :original_filename, limit: 255
      t.string   :original_type,     limit: 255
      t.integer  :user_id

      t.string :url, limit: 255

      t.string :title
      t.jsonb :description # includes "area", "sub-area", number of people, severity. all configurable attributes stored in simple config
      t.string :note
      t.string :url
      t.integer :affected_people_count
      t.integer :violation_severity
      t.float :violation_coefficient
      t.integer :positivity_rating_id
      t.integer :reminder_id
      t.timestamps
    end
  end
end
