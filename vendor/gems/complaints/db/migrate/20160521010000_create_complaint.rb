class CreateComplaint < ActiveRecord::Migration[4.2]
  def change
    create_table :complaints, :force => true do |t|
      t.string :case_reference
      t.string :complainant
      t.string :village
      t.string :phone
      t.timestamps
    end

    create_table :complaint_bases, :force => true do |t|
      t.string :name
      t.string :type
      t.timestamps
    end

    create_table :complaint_complaint_bases, :force => true do |t|
      t.integer :complaint_id
      t.integer :complaint_basis_id
      t.string :type
      t.timestamps
    end

    create_table :complaint_conventions, :force => true do |t|
      t.integer :complaint_id
      t.integer :convention_id
      t.timestamps
    end

    create_table :assigns, :force => true do |t|
      t.integer :complaint_id
      t.integer :user_id
      t.timestamps
    end

    create_table :complaint_documents, :force => true do |t|
      t.integer  "complaint_id"
      t.string   "file_id",          limit: 255
      t.string   "title",            limit: 255
      t.integer  "filesize"
      t.string   "filename",         limit: 255
      t.datetime "lastModifiedDate"
      t.string   "original_type",    limit: 255
      t.integer  "user_id"
      t.timestamps
    end

    create_table :complaint_categories, :force => true do |t|
      t.string :name
      t.timestamps
    end

    create_table :complaint_complaint_categories, :force => true do |t|
      t.integer :complaint_id
      t.integer :complaint_category_id
      t.timestamps
    end
  end
end
