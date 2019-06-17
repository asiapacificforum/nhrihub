class AddIndexAttributeToStrategicPlanTables < ActiveRecord::Migration[4.2]
  def change
    add_column :planned_results, :index, :string, :limit => 10
    add_column :outcomes, :index, :string, :limit => 10
    add_column :activities, :index, :string, :limit => 10
    add_column :performance_indicators, :index, :string, :limit => 10
  end
end
