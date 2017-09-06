class AddViolationSeverityAssociationToMediaAppearances < ActiveRecord::Migration
  def change
    remove_column :media_appearances, :violation_severity
    add_column :media_appearances, :violation_severity_id, :integer
  end
end
