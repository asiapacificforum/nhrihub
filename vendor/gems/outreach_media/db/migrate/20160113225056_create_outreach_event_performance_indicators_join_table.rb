class CreateOutreachEventPerformanceIndicatorsJoinTable < ActiveRecord::Migration
  def change
    create_table :outreach_event_performance_indicators do |t|
      t.integer :outreach_event_id
      t.integer :performance_indicator_id
      t.timestamps
    end
  end
end
