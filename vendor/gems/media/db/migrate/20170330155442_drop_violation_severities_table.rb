class DropViolationSeveritiesTable < ActiveRecord::Migration[5.0]
  def change
    drop_table :violation_severities

    remove_column :advisory_council_issues, :violation_coefficient
    remove_column :advisory_council_issues, :violation_severity_id
    remove_column :media_appearances, :violation_coefficient
    remove_column :media_appearances, :violation_severity_id
  end
end
