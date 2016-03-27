class AddNhriIndicatorTables < ActiveRecord::Migration
  def change
    create_table :headings do |t|
      t.string :title
      t.timestamps
    end

    create_table :offences do |t|
      t.string :description
      t.integer :heading_id
      t.timestamps
    end

    create_table :indicators do |t|
      t.string :title
      t.integer :offence_id
      t.integer :heading_id
      t.string :nature
      t.string :monitor_format
      t.string :numeric_monitor_explanation
      t.timestamps
    end

    create_table :numeric_monitors do |t|
      t.integer :indicator_id
      t.integer :author_id
      t.datetime :date
      t.integer :value
      t.timestamps
    end

    create_table :text_monitors do |t|
      t.integer :indicator_id
      t.integer :author_id
      t.datetime :date
      t.string :description
      t.timestamps
    end

    create_table :file_monitors do |t|
      t.integer :indicator_id
      t.integer :user_id
      t.datetime "lastModifiedDate"
      t.string   "file_id",               limit: 255
      t.integer  "filesize"
      t.string   "original_filename",     limit: 255
      t.string   "original_type",         limit: 255
      t.timestamps
    end
  end
end
