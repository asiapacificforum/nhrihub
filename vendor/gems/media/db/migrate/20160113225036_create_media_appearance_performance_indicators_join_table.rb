class CreateMediaAppearancePerformanceIndicatorsJoinTable < ActiveRecord::Migration
  def change
    create_table :media_appearance_performance_indicators do |t|
      t.integer :media_appearance_id
      t.integer :performance_indicator_id
      t.timestamps
    end
  end
end
