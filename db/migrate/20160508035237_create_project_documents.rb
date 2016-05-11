class CreateProjectDocuments < ActiveRecord::Migration
  def change
    create_table :project_documents do |t|
      t.integer  "project_id"
      t.string   "file_id",           limit: 255
      t.string   "title",             limit: 255
      t.integer  "filesize"
      t.string   "original_filename", limit: 255
      t.datetime "lastModifiedDate"
      t.string   "original_type",     limit: 255
      t.integer  "user_id"
      t.timestamps
    end
  end
end
