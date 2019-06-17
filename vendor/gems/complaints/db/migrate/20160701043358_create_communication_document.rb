class CreateCommunicationDocument < ActiveRecord::Migration[4.2]
  def change
    create_table :communication_documents, :force => true do |t|
      t.integer  "communication_id"
      t.string   "file_id",          limit: 255
      t.string   "title",            limit: 255
      t.integer  "filesize"
      t.string   "filename",         limit: 255
      t.datetime "lastModifiedDate"
      t.string   "original_type",    limit: 255
      t.integer  "user_id"
      t.timestamps
    end
  end
end
