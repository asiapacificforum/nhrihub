class CreateComplaint < ActiveRecord::Migration
  def change
    create_table :complaints do |t|
      t.string :case_reference
      t.string :complainant
      t.string :village
      t.string :phone
      t.boolean :status
      t.datetime :closed_on
      t.integer :closed_by_id
      t.integer :opened_by_id
      t.string :type
      t.timestamps
    end

    create_table :complaint_bases do |t|
      t.string :name
      t.string :type
      t.timestamps
    end

    create_table :complaint_complaint_bases do |t|
      t.integer :complaint_id
      t.integer :complaint_basis_id
      t.timestamps
    end

    create_table :complaint_conventions do |t|
      t.integer :complaint_id
      t.integer :convention_id
      t.timestamps
    end

    create_table :assigns do |t|
      t.integer :complaint_id
      t.integer :user_id
      t.timestamps
    end

    create_table :complaint_documents do |t|
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
  end
end
