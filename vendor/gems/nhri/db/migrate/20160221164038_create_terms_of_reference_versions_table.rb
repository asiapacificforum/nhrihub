class CreateTermsOfReferenceVersionsTable < ActiveRecord::Migration[4.2]
  def change
    create_table :terms_of_reference_versions, :force => true do |t|
      t.string   "file_id",           limit: 255
      t.integer  "filesize"
      t.string   "original_filename", limit: 255
      t.integer  "revision_major"
      t.integer  "revision_minor"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.datetime "lastModifiedDate"
      t.string   "original_type",     limit: 255
      t.integer  "user_id"
    end
  end
end
