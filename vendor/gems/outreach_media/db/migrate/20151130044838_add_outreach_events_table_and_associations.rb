class AddOutreachEventsTableAndAssociations < ActiveRecord::Migration
  def change
    create_table :outreach_events do |t|
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

    create_table :outreach_event_areas do |t|
      t.integer :outreach_event_id
      t.integer :area_id
      t.timestamps
    end

    create_table :outreach_event_subareas do |t|
      t.integer :outreach_event_id
      t.integer :subarea_id
      t.timestamps
    end

    create_table :impact_ratings do |t|
      t.integer :rank
      t.string :text
      t.timestamps
    end

    create_table :outreach_event_documents do |t|
      t.integer  :outreach_event_id
      t.string   :file_id,           limit: 255
      t.integer  :filesize
      t.string   :original_filename, limit: 255
      t.string   :original_type,     limit: 255
      t.timestamps
    end

    create_table :audience_types do |t|
      t.string :short_type
      t.string :long_type
      t.timestamps
    end
  end
end
