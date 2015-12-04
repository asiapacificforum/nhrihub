class AddPerformanceIndicatorsTable < ActiveRecord::Migration
  def change
    create_table :performance_indicators do |t|
      t.integer :activity_id
      t.text :description
      t.text :target
      t.timestamps
    end

    remove_column :activities,:performance_indicator
    remove_column :activities,:target
  end
end
