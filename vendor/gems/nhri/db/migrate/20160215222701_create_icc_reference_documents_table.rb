class CreateIccReferenceDocumentsTable < ActiveRecord::Migration[4.2]
  def change
    create_table :icc_reference_documents, :force => true do |t|
      t.string   :source_url
      t.string   :title
      t.integer  :filesize
      t.string   :original_filename, limit: 255
      t.datetime :created_at
      t.datetime :updated_at
      t.string   :original_type,     limit: 255
      t.integer  :user_id
    end
  end
end
