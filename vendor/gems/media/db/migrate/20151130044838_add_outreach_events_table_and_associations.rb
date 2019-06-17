class AddOutreachEventsTableAndAssociations < ActiveRecord::Migration[4.2]
  def change
    create_table :outreach_events, :force => true do |t|
      t.string :title
      t.datetime :event_date
      t.integer :audience_type_id
      t.string :audience_name
      t.integer :participant_count
      t.integer :affected_people_count
      t.text :description
      t.integer :impact_rating_id
      t.timestamps
    end

    create_table :outreach_event_areas, :force => true do |t|
      t.integer :outreach_event_id
      t.integer :area_id
      t.timestamps
    end

    create_table :outreach_event_subareas, :force => true do |t|
      t.integer :outreach_event_id
      t.integer :subarea_id
      t.timestamps
    end

    create_table :impact_ratings, :force => true do |t|
      t.integer :rank
      t.string :text
      t.timestamps
    end

    create_table :outreach_event_documents, :force => true do |t|
      t.integer  :outreach_event_id
      t.string   :file_id,           limit: 255
      t.integer  :filesize
      t.string   :original_filename, limit: 255
      t.string   :original_type,     limit: 255
      t.timestamps
    end

    create_table :audience_types, :force => true do |t|
      t.string :short_type
      t.string :long_type
      t.timestamps
    end
  end
end
