class DropObsoleteOutreachEventDependencyTables < ActiveRecord::Migration[5.0]
  def change
    drop_table :outreach_event_areas
    drop_table :outreach_event_documents
    drop_table :outreach_event_performance_indicators
    drop_table :outreach_event_subareas
    drop_table :outreach_events
  end
end
