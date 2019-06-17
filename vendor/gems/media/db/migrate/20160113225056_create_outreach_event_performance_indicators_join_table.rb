class CreateOutreachEventPerformanceIndicatorsJoinTable < ActiveRecord::Migration[4.2]
  def change
    create_table :outreach_event_performance_indicators, :force => true do |t|
      t.integer :outreach_event_id
      t.integer :performance_indicator_id
      t.timestamps
    end
  end
end
