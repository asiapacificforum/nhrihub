class CreateViolationSeverities < ActiveRecord::Migration
  def change
    create_table :violation_severities do |t|
      t.integer :rank
      t.string :text
      t.timestamps
    end
  end
end
